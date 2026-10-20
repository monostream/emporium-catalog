"""Fill the Supabase keys Secret.

Helm creates SECRET_NAME empty (the manifest has no data, so upgrades never reset
it); this script only reads and updates that one Secret.

- The anon and service_role keys are HS256 JWTs signed with the JWT secret. They
  are signed once, when the Secret holds no keys yet, and never re-signed.
- If the Secret already holds a different JWT secret, the script fails without
  writing: re-signing would invalidate every client key and session.
- The SMTP user and password (upstream reads both from one Secret) are copied on
  every run.
"""
import base64
import hashlib
import hmac
import json
import os
import ssl
import sys
import time
import urllib.error
import urllib.request

SA = "/var/run/secrets/kubernetes.io/serviceaccount"
API = "https://{}:{}".format(os.environ["KUBERNETES_SERVICE_HOST"], os.environ["KUBERNETES_SERVICE_PORT"])
NS = open(SA + "/namespace").read().strip()
TOKEN = open(SA + "/token").read().strip()
CTX = ssl.create_default_context(cafile=SA + "/ca.crt")
SECRET_NAME = os.environ["SECRET_NAME"]
JWT_SECRET = os.environ["JWT_SECRET"]
SMTP = {"smtpUsername": os.environ.get("SMTP_USERNAME", ""), "smtpPassword": os.environ.get("SMTP_PASSWORD", "")}
TEN_YEARS = 10 * 365 * 24 * 3600


def call(method, path, body=None):
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(API + path, data=data, method=method, headers={
        "Authorization": "Bearer " + TOKEN,
        "Content-Type": "application/json",
        "Accept": "application/json",
    })
    try:
        with urllib.request.urlopen(req, context=CTX, timeout=30) as resp:
            return json.load(resp)
    except urllib.error.HTTPError as err:
        sys.exit("{} {}: {} {}".format(method, path, err.code, err.read().decode(errors="replace")[:300]))


def b64url(raw):
    return base64.urlsafe_b64encode(raw).rstrip(b"=").decode()


def sign(role, now):
    header = b64url(json.dumps({"alg": "HS256", "typ": "JWT"}, separators=(",", ":")).encode())
    claims = {"role": role, "iss": "supabase", "iat": now, "exp": now + TEN_YEARS}
    payload = b64url(json.dumps(claims, separators=(",", ":")).encode())
    sig = hmac.new(JWT_SECRET.encode(), "{}.{}".format(header, payload).encode(), hashlib.sha256).digest()
    return "{}.{}.{}".format(header, payload, b64url(sig))


def main():
    if len(JWT_SECRET) < 32:
        sys.exit("the JWT secret must have at least 32 characters")
    path = "/api/v1/namespaces/{}/secrets/{}".format(NS, SECRET_NAME)
    current = call("GET", path)
    data = {k: base64.b64decode(v).decode() for k, v in (current.get("data") or {}).items()}

    want = dict(data)
    stored = data.get("secret", "")
    if stored or data.get("anonKey") or data.get("serviceKey"):
        if not hmac.compare_digest(stored, JWT_SECRET):
            sys.exit("Secret {} holds API keys signed with a different JWT secret; not re-signing them. "
                     "Set the JwtSecret input back to the stored value.".format(SECRET_NAME))
        if not (data.get("anonKey") and data.get("serviceKey")):
            sys.exit("Secret {} is incomplete (JWT secret without API keys); not re-signing.".format(SECRET_NAME))
    else:
        now = int(time.time())
        want.update(secret=JWT_SECRET, anonKey=sign("anon", now), serviceKey=sign("service_role", now))
    want.update(SMTP)

    if want == data:
        print("Secret {} is up to date".format(SECRET_NAME))
        return
    current["data"] = {k: base64.b64encode(v.encode()).decode() for k, v in want.items()}
    current.pop("stringData", None)
    call("PUT", path, current)
    print("Secret {} updated ({})".format(SECRET_NAME, ", ".join(sorted(k for k in want if want[k] != data.get(k)))))


main()
