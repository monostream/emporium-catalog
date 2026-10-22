#!/bin/sh
# The image entrypoint installs LimeSurvey with `console.php install <user> <password> ...`,
# which would put the real administrator password into the process arguments. Let it install
# with a throwaway password; post.sh then replaces it in-process (before Apache starts)
# with the real one from the Secret.
set -eu
# The throwaway is derived from the real password (HMAC), so it is useless without it and a start that
# crashed between the install and the replacement is repaired by the next start.
ADMIN_PASSWORD="$(php -r 'echo substr(hash_hmac("sha256", "limesurvey-bootstrap", (string) getenv("ADMIN_BOOTSTRAP_PASSWORD")), 0, 32);')"
export ADMIN_PASSWORD
exec /usr/local/bin/entrypoint.sh /scripts/post.sh
