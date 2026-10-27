#!/bin/sh
set -eu
cd /var/www/html
php /scripts/set-admin.php
unset ADMIN_BOOTSTRAP_PASSWORD ADMIN_PASSWORD
exec apache2-foreground
