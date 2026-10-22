#!/usr/bin/env python3
"""Kavita first-start setup, run as a sidecar next to the app.

Idempotent. Talks to Kavita on localhost, never through the ingress.
  1. creates the first administrator (so nobody can claim it from the browser)
  2. applies the server settings Emporium manages (OIDC account provisioning,
     statistics off, optional auto-login)
  3. on the very first run creates a default Book library and makes it the
     default library of new single sign-on accounts
  4. writes READY_FILE (a per-pod emptyDir); the pod's readiness probe tests it,
     so the Service gets no endpoint before the administrator exists
If the administrator exists but the Secret's password no longer works (it was
changed in Kavita), the account is taken over by its owner: setup reports ready
and leaves the settings alone, but only when a marker on the config volume shows
that the settings were applied once; otherwise it stays unready and retries.
Credentials come from the environment; nothing is printed except status lines.
"""
import json
import os
import sys
import time
import urllib.error
import urllib.request

BASE = os.environ.get("KAVITA_URL", "http://127.0.0.1:5000").rstrip("/")
USER = os.environ["ADMIN_USERNAME"]
PASSWORD = os.environ["ADMIN_PASSWORD"]
OIDC = os.environ.get("OIDC_ENABLED") == "1"
AUTO_LOGIN = os.environ.get("OIDC_AUTO_LOGIN") == "1"
LIBRARY_DIR = os.environ.get("LIBRARY_DIR", "/data/library")
MARKER = os.environ.get("MARKER", "/config/.emporium-setup-done")
READY_FILE = os.environ.get("READY_FILE", "/status/ready")
# Persistent proof that the settings were applied once (on the config volume).
APPLIED = os.environ.get("APPLIED_MARKER", "/config/.emporium-settings-applied")
DEFAULT_ROLES = ["Login", "Pleb", "Download"]


def log(msg):
    print("setup: " + msg, flush=True)


class HttpError(RuntimeError):
    def __init__(self, msg, code):
        super().__init__(msg)
        self.code = code


def call(method, path, body=None, token=None, ok=(200,)):
    data = None if body is None else json.dumps(body).encode()
    req = urllib.request.Request(BASE + path, data=data, method=method)
    if body is not None:
        req.add_header("Content-Type", "application/json")
    if token:
        req.add_header("Authorization", "Bearer " + token)
    try:
        with urllib.request.urlopen(req, timeout=30) as r:
            raw = r.read()
            code = r.status
    except urllib.error.HTTPError as e:
        raw, code = e.read(), e.code
    if code not in ok:
        detail = ""
        if not path.startswith("/api/account/"):
            detail = ": " + raw.decode(errors="replace")[:300]
        raise HttpError("%s %s -> HTTP %s%s" % (method, path, code, detail), code)
    try:
        return json.loads(raw) if raw else None
    except ValueError:
        return raw.decode(errors="replace")


def wait_ready():
    for _ in range(360):
        try:
            call("GET", "/api/health")
            return
        except Exception:
            time.sleep(5)
    raise RuntimeError("Kavita did not become ready")


def sign_in():
    """Returns a token, or None when an administrator exists but our password no longer works."""
    try:
        return call("POST", "/api/account/login", {"username": USER, "password": PASSWORD})["token"]
    except HttpError as e:
        if e.code >= 500:
            raise  # server trouble is not a wrong password: retry
    if call("GET", "/api/admin/exists") is True:
        return None
    # Unknown user: this is the first start, register the first administrator.
    # Kavita refuses the call as soon as any administrator exists.
    call("POST", "/api/account/register", {"username": USER, "password": PASSWORD})
    log("created the first administrator")
    return call("POST", "/api/account/login", {"username": USER, "password": PASSWORD})["token"]


def first_run(token, settings):
    """Default library for new accounts; only once, so deleting it sticks."""
    if os.path.exists(MARKER):
        return False
    libs = call("GET", "/api/library/libraries", token=token) or []
    lib_id = libs[0]["id"] if libs else None
    if lib_id is None:
        folder = os.path.join(LIBRARY_DIR, "books")
        os.makedirs(folder, exist_ok=True)
        lib = call("POST", "/api/library/create", {
            "id": 0, "name": "Books", "type": 2, "folders": [folder],
            "folderWatching": True, "includeInDashboard": True, "includeInSearch": True,
            "manageCollections": True, "manageReadingLists": True,
            "allowScrobbling": False, "allowMetadataMatching": False, "enableMetadata": True,
            "removePrefixForSortName": False, "inheritWebLinksFromFirstChapter": False,
            "fileGroupTypes": [2, 3], "excludePatterns": [], "metadataProvider": 2,
        }, token=token, ok=(200, 201, 204))
        libs = call("GET", "/api/library/libraries", token=token) or []
        lib_id = libs[0]["id"] if libs else None
        log("created the default library")
    if lib_id is not None:
        settings["oidcConfig"]["defaultLibraries"] = [lib_id]
    return True


def apply():
    wait_ready()
    token = sign_in()
    if token is None:
        if os.path.exists(APPLIED):
            log("the administrator exists and its password was changed: leaving the settings to its owner")
            return
        # An administrator exists but the settings were never applied (partial first start).
        raise RuntimeError("the administrator exists, the login fails and the settings were never applied; retrying")
    settings = call("GET", "/api/settings", token=token)
    before = json.dumps(settings, sort_keys=True)

    settings["allowStatCollection"] = False
    if OIDC:
        oc = settings["oidcConfig"]
        oc["provisionAccounts"] = True
        # Emporium (Logto) only lets administrators set e-mail addresses.
        oc["requireVerifiedEmail"] = False
        # Kavita can map roles only from claims named like its own roles, which
        # Emporium roles are not; accounts get the defaults below, the
        # administrator promotes users in Kavita.
        oc["syncUserSettings"] = False
        oc["autoLogin"] = AUTO_LOGIN
        oc["providerName"] = "Emporium"
        if not oc.get("defaultRoles"):
            oc["defaultRoles"] = DEFAULT_ROLES
            # No age restriction: books usually carry no age rating, and "Unknown"
            # (Kavita's default for new accounts) would hide them from every reader.
            oc["defaultAgeRestriction"] = -1
            oc["defaultIncludeUnknowns"] = True
    first = first_run(token, settings)

    if json.dumps(settings, sort_keys=True) != before:
        call("POST", "/api/settings", settings, token=token)
        log("settings applied")
    else:
        log("settings already up to date")
    try:
        open(APPLIED, "w").close()
    except OSError as e:
        log("cannot write the marker: %s" % e)
    if first:
        try:
            open(MARKER, "w").close()
        except OSError as e:
            log("cannot write the marker: %s" % e)


def main():
    attempt = 0
    while True:
        attempt += 1
        try:
            apply()
            break
        except Exception as e:  # stay unready and retry
            log("attempt %d failed: %s" % (attempt, e))
            time.sleep(30)
    with open(READY_FILE, "w") as f:
        f.write("ready\n")
    log("ready")
    while True:
        time.sleep(3600)


if __name__ == "__main__":
    sys.exit(main())
