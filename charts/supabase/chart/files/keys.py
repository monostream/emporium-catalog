"""Write the Supabase keys Secret.

The anon and service_role keys are HS256 JWTs signed with the JWT secret. This
script signs them and writes them, with the JWT secret and the SMTP credentials
(upstream reads SMTP user and password from one Secret), into SECRET_NAME. The
Secret is owned by the ConfigMap OWNER_CONFIGMAP (part of the Helm release), so
uninstalling the release deletes it. The API keys are re-signed only when the
JWT secret changes, so they stay stable.
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
OWNER = os.environ["OWNER_CONFIGMAP"]
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
            return resp.status, json.load(resp)
    except urllib.error.HTTPError as err:
        if err.code == 404:
            return 404, None
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
    status, current = call("GET", path)
    data, same_jwt = {}, False
    if status == 200:
        data = {k: base64.b64decode(v).decode() for k, v in (current.get("data") or {}).items()}
        same_jwt = bool(hmac.compare_digest(data.get("secret", ""), JWT_SECRET) and data.get("anonKey") and data.get("serviceKey"))
        if same_jwt and all(hmac.compare_digest(data.get(k, ""), v) for k, v in SMTP.items()):
            print("Secret {} is up to date".format(SECRET_NAME))
            return
    _, owner = call("GET", "/api/v1/namespaces/{}/configmaps/{}".format(NS, OWNER))
    if owner is None:
        sys.exit("owner ConfigMap {} not found".format(OWNER))
    keys = {"secret": JWT_SECRET, "anonKey": data.get("anonKey"), "serviceKey": data.get("serviceKey")}
    if not same_jwt:
        now = int(time.time())
        keys["anonKey"], keys["serviceKey"] = sign("anon", now), sign("service_role", now)
    body = {
        "apiVersion": "v1",
        "kind": "Secret",
        "type": "Opaque",
        "metadata": {
            "name": SECRET_NAME,
            "labels": {"app.kubernetes.io/part-of": "supabase", "app.kubernetes.io/component": "keys"},
            "ownerReferences": [{
                "apiVersion": "v1", "kind": "ConfigMap",
                "name": OWNER, "uid": owner["metadata"]["uid"],
            }],
        },
        "stringData": dict(keys, **SMTP),
    }
    if status == 200:
        body["metadata"]["resourceVersion"] = current["metadata"]["resourceVersion"]
        call("PUT", path, body)
        print("Secret {} updated".format(SECRET_NAME))
    else:
        call("POST", "/api/v1/namespaces/{}/secrets".format(NS), body)
        print("Secret {} created".format(SECRET_NAME))


main()
