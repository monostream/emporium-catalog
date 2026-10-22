#!/bin/sh
# First-start setup of Stalwart through its bootstrap API; idempotent.
# A fresh volume has no config.json: Stalwart then starts in bootstrap mode, serves only the
# setup API on the HTTP port and accepts the administrator from STALWART_RECOVERY_ADMIN.
# This script completes the setup (host name, first domain, RocksDB path, logging to stdout);
# Stalwart writes config.json and the main container restarts into normal mode.
# The response of the setup call contains a generated password for admin@<domain>; it is
# never printed or stored (the administrator from the chart's Secret is the way in).
set -u
BASE="http://127.0.0.1:${HTTP_PORT}"
AUTH="${ADMIN_USERNAME}:${ADMIN_PASSWORD}"
jmap() { curl -s -m 30 -u "$AUTH" -H 'Content-Type: application/json' "$BASE/jmap" -d "$1"; }
until curl -sf -m 3 "$BASE/healthz/live" >/dev/null 2>&1; do sleep 2; done
while true; do
  acc=$(curl -s -m 10 -u "$AUTH" "$BASE/jmap/session" | sed -n 's/.*"primaryAccounts":{[^}]*"urn:ietf:params:jmap:mail":"\([^"]*\)".*/\1/p')
  if [ -z "$acc" ]; then echo "waiting for the management API"; sleep 5; continue; fi
  cur=$(jmap "{\"using\":[\"urn:ietf:params:jmap:core\",\"urn:stalwart:jmap\"],\"methodCalls\":[[\"x:Bootstrap/get\",{\"accountId\":\"$acc\",\"ids\":[\"singleton\"]},\"c1\"]]}")
  case "$cur" in
    *'"serverHostname"'*)
      echo "bootstrap mode: configuring ${SERVER_HOSTNAME} / ${DEFAULT_DOMAIN}"
      res=$(jmap "{\"using\":[\"urn:ietf:params:jmap:core\",\"urn:stalwart:jmap\"],\"methodCalls\":[[\"x:Bootstrap/set\",{\"accountId\":\"$acc\",\"update\":{\"singleton\":{\"serverHostname\":\"${SERVER_HOSTNAME}\",\"defaultDomain\":\"${DEFAULT_DOMAIN}\",\"requestTlsCertificate\":false,\"dataStore\":{\"@type\":\"RocksDb\",\"path\":\"/var/lib/stalwart/data\"},\"tracer\":{\"@type\":\"Stdout\"}}}},\"c1\"]]}")
      case "$res" in
        *'"updated"'*) echo "bootstrap complete; the server restarts into normal mode" ;;
        *) echo "bootstrap failed: $(echo "$res" | sed -E 's/"secret":"[^"]*"/"secret":"-"/g' | head -c 400)" ;;
      esac
      ;;
    *'"notFound":["singleton"]'*) echo "configured; nothing to do"; break ;;
    *) echo "unexpected answer: $(echo "$cur" | head -c 200)" ;;
  esac
  sleep 10
done
# Keep the container (and its pod) running; the loop above ends after the setup.
while true; do sleep 3600; done
