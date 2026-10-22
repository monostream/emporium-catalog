"""Prepares Calibre-Web Automated before the app starts (init container, runs as root).

1. Creates app.db the way the image's own init does when it is missing.
2. Replaces the default administrator (admin / admin123) with the configured account.
   The default password is never left in place: if it still works after this step, the
   script fails and the pod does not start.
3. Writes the OpenID Connect provider (client secret from the environment, delivered by
   reference) and switches the login type to OAuth. The standard login form stays, so the
   local administrator can always sign in.
Everything is idempotent and safe to repeat at every start.
"""
import os
import re
import sqlite3
import subprocess
import sys

from werkzeug.security import check_password_hash, generate_password_hash

CONFIG = "/config"
DB = os.path.join(CONFIG, "app.db")
APP_DIR = "/app/calibre-web-automated"
DEFAULT_PASSWORD = "admin123"
ROLE_DOWNLOAD, ROLE_PASSWD, ROLE_EDIT_SHELFS, ROLE_VIEWER = 1 << 1, 1 << 4, 1 << 6, 1 << 8
PUID = int(os.environ.get("PUID", "1000"))
PGID = int(os.environ.get("PGID", "1000"))


def log(msg):
    print("[emporium-setup] " + msg, flush=True)


def chown_tree(path):
    for root, dirs, files in os.walk(path):
        for name in [root] + [os.path.join(root, n) for n in dirs + files]:
            try:
                os.chown(name, PUID, PGID)
            except OSError:
                pass


def create_db():
    """Runs the image's own non-serving init (cps.py -d): it creates app.db when it is missing and
    otherwise applies the app's schema migrations, which the OIDC columns below depend on.
    Returns True when app.db was created now."""
    created = not os.path.exists(DB)
    log("creating app.db" if created else "app.db exists, applying the app's migrations")
    env = dict(os.environ, CALIBRE_DBPATH=CONFIG, HOME=CONFIG)
    res = subprocess.run(
        ["/lsiopy/bin/python3", os.path.join(APP_DIR, "cps.py"), "-d"],
        cwd=APP_DIR, env=env, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=300)
    if not os.path.exists(DB) or res.returncode != 0:
        log("init failed (exit %s):\n%s" % (res.returncode, res.stdout.decode(errors="replace")[-2000:]))
        sys.exit(1)
    if not created:
        return False
    con = sqlite3.connect(DB)
    # Same step as the image's own init: point Calibre-Web at the bundled kepubify.
    con.execute("update settings set config_kepubifypath='/usr/bin/kepubify' "
                "where config_kepubifypath is NULL or LENGTH(config_kepubifypath)=0")
    # First-start defaults (an administrator may change them later in the app):
    # - Session protection "basic": the default "strong" ends a session whenever the client address
    #   the app sees changes, and behind the ingress it is a different proxy pod per request.
    # - New accounts (single sign-on) can read and download books, change their own password
    #   (needed for OPDS) and manage their own shelves; the stock default is no rights at all.
    con.execute("update settings set config_session=0, config_default_role=?",
                (ROLE_VIEWER | ROLE_DOWNLOAD | ROLE_PASSWD | ROLE_EDIT_SHELFS,))
    con.commit()
    con.close()
    return True


def check_admin_username(username):
    """Single sign-on accounts are named by the provider's subject id (Logto: 12 lowercase
    alphanumeric characters) and CWA matches an incoming login to an existing account by username
    (exact, case-sensitive) and then by e-mail. A local name containing '-', '_' or '.' can never
    equal a subject id, so such names are required; a name shaped like a subject id is refused."""
    if (re.fullmatch(r"[a-z0-9]{12}", username) or not re.search(r"[._-]", username)
            or not 2 <= len(username) <= 32
            or not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9._-]*", username)):
        log("the administrator username must be 2-32 characters of letters, digits, '.', '_', '-', start with a "
            "letter or digit and contain '-', '_' or '.' (so it can never equal a single sign-on subject id)")
        sys.exit(1)


def replace_default_admin(con):
    username = os.environ.get("ADMIN_USERNAME", "").strip()
    password = os.environ.get("ADMIN_PASSWORD", "")
    rows = con.execute("select id, name, password from user").fetchall()
    default_rows = [r for r in rows if r[2] and check_password_hash(r[2], DEFAULT_PASSWORD)]
    if not default_rows:
        log("no account with the default password")
        return
    if not username or not password:
        log("ADMIN_USERNAME and ADMIN_PASSWORD are required to replace the default account")
        sys.exit(1)
    taken = {r[1].lower() for r in rows if r not in default_rows}
    if username.lower() in taken:
        log("the administrator username is already used by another account")
        sys.exit(1)
    check_admin_username(username)
    uid = default_rows[0][0]
    con.execute("update user set name=?, password=? where id=?",
                (username, generate_password_hash(password), uid))
    for r in default_rows[1:]:
        con.execute("update user set password=? where id=?", ("", r[0]))
    con.commit()
    log("replaced the default administrator with %r" % username)


def configure_oidc(con):
    if os.environ.get("OIDC_ENABLED") != "1":
        log("single sign-on is not configured")
        return
    issuer = os.environ["OIDC_ISSUER"].rstrip("/")
    client_id = os.environ["OIDC_CLIENT_ID"]
    secret = os.environ["OIDC_CLIENT_SECRET"]
    host = os.environ.get("PUBLIC_URL", "").rstrip("/")
    # The application creates the github and google rows only when the table is empty,
    # and expects them next to the generic row.
    for name in ("github", "google"):
        if not con.execute("select 1 from oauthProvider where provider_name=?", (name,)).fetchone():
            con.execute("insert into oauthProvider (provider_name, active) values (?, 0)", (name,))
    row = con.execute("select id from oauthProvider where provider_name='generic'").fetchone()
    values = (client_id, secret, issuer + "/.well-known/openid-configuration",
              "openid profile email", "sub", "sub",
              os.environ.get("OIDC_BUTTON", "Emporium"))
    if row:
        con.execute("update oauthProvider set oauth_client_id=?, oauth_client_secret=?, metadata_url=?, "
                    "scope=?, username_mapper=?, email_mapper=?, login_button=?, active=1 "
                    "where provider_name='generic'", values)
    else:
        con.execute("insert into oauthProvider (oauth_client_id, oauth_client_secret, metadata_url, "
                    "scope, username_mapper, email_mapper, login_button, active, provider_name) "
                    "values (?,?,?,?,?,?,?,1,'generic')", values)
    # Username and email both come from the stable subject id. CWA links an incoming login to an
    # existing local account with the same username, so a name chosen by the user (preferred_username)
    # could take over the local administrator. Subject ids are 12 lowercase alphanumeric characters,
    # so a local account whose name contains '-', '_' or '.' cannot equal one (the break-glass
    # administrator is required to; see check_admin_username). Accounts created later in the CWA UI
    # are not checked and should follow the same rule. The email fallback uses the subject id too.
    # The email column is also unique and Emporium users usually have no email.
    # login type 2 = OAuth (the standard login form stays available)
    con.execute("update settings set config_login_type=2, config_oauth_redirect_host=?", (host,))
    con.commit()
    log("single sign-on configured for %s" % issuer)


def main():
    create_db()
    # Wait for a writer instead of failing: nothing else uses the file at this point.
    con = sqlite3.connect(DB, timeout=30)
    replace_default_admin(con)
    configure_oidc(con)
    for name, pw in con.execute("select name, password from user"):
        if pw and check_password_hash(pw, DEFAULT_PASSWORD):
            log("account %r still has the default password" % name)
            sys.exit(1)
    con.close()
    chown_tree(CONFIG)
    log("done")


main()
