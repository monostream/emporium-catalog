<?php
// Runs in an init container before Grocy serves any request, and fails closed.
// Grocy creates the account "admin" with the password "admin" when it migrates an
// empty database (normally on the first request to "/"). This migrates the database
// first and replaces that password with the one from ADMIN_PASSWORD. An account whose
// password is no longer "admin" (changed in the UI) is left alone.
define('GROCY_IS_EMBEDDED_INSTALL', false);
define('GROCY_DATAPATH', getenv('GROCY_DATAPATH') ?: '/config/data');

$password = getenv('ADMIN_PASSWORD');
if ($password === false || strlen($password) < 8) {
    fwrite(STDERR, "ADMIN_PASSWORD is missing or shorter than 8 characters\n");
    exit(1);
}
if ($password === 'admin') {
    fwrite(STDERR, "ADMIN_PASSWORD must not be the default\n");
    exit(1);
}

// Security settings are chart-owned. Grocy reads every setting from (1) data/settingoverrides/<NAME>.txt,
// (2) the environment (GROCY_<NAME>), (3) config.php, in that order, so a restored volume could switch
// to reverse-proxy login (trusting a header that clients can send on the skipped /api/* paths) or disable
// authentication. Remove such override files, then check the effective result below.
const CHART_OWNED = ['AUTH_CLASS', 'DISABLE_AUTH', 'MODE', 'REVERSE_PROXY_AUTH_HEADER', 'REVERSE_PROXY_AUTH_USE_ENV',
    'LDAP_ADDRESS', 'LDAP_BASE_DN', 'LDAP_BIND_DN', 'LDAP_BIND_PW', 'LDAP_DOMAIN', 'LDAP_USER_FILTER', 'LDAP_UID_ATTR'];
foreach (CHART_OWNED as $name) {
    $f = GROCY_DATAPATH . '/settingoverrides/' . $name . '.txt';
    if (is_file($f)) {
        if (!unlink($f)) {
            fwrite(STDERR, "cannot remove the settings override $f\n");
            exit(1);
        }
        echo "removed persisted settings override $name.txt (chart-owned security setting)\n";
    }
}

// The web runtime also gets environment from PHP-FPM pool files on the volume (the image includes
// /config/php/*.conf, with clear_env = no). Strip GROCY_* and FILE__* env lines so they cannot inject
// settings that this check does not see.
foreach (glob('/config/php/*.conf') ?: [] as $conf) {
    $lines = file($conf);
    if ($lines === false) {
        fwrite(STDERR, "cannot read $conf\n");
        exit(1);
    }
    $kept = [];
    foreach ($lines as $line) {
        if (preg_match('/^\s*env\s*\[\s*(GROCY_|FILE__)/i', $line)) {
            echo "removed env line for " . trim(strstr($line, '=', true) ?: $line) . " from $conf (chart-owned)\n";
            continue;
        }
        $kept[] = $line;
    }
    if (count($kept) !== count($lines) && file_put_contents($conf, implode('', $kept)) === false) {
        fwrite(STDERR, "cannot rewrite $conf\n");
        exit(1);
    }
}

// Same first-start layout the image creates (config.php from config-dist.php).
if (!is_dir(GROCY_DATAPATH) && !mkdir(GROCY_DATAPATH, 0775, true)) {
    fwrite(STDERR, "cannot create " . GROCY_DATAPATH . "\n");
    exit(1);
}
if (!is_file(GROCY_DATAPATH . '/config.php')) {
    copy('/app/www/config-dist.php', GROCY_DATAPATH . '/config.php');
}

require_once '/app/www/packages/autoload.php';
require_once GROCY_DATAPATH . '/config.php';
require_once '/app/www/config-dist.php';

// Effective settings, evaluated by Grocy's own Setting() code exactly as the application does
// (overrides, then GROCY_* environment, then config.php, then config-dist.php).
if (GROCY_AUTH_CLASS !== 'Grocy\\Middleware\\Auth\\DefaultAuthMiddleware' || GROCY_MODE !== 'production' || GROCY_DISABLE_AUTH !== false) {
    fwrite(STDERR, "refusing to start: effective settings are not default authentication, production mode and authentication enabled "
        . "(check config.php and GROCY_* environment variables)\n");
    exit(1);
}

use Grocy\Services\DatabaseMigrationService;
use Grocy\Services\DatabaseService;

DatabaseMigrationService::GetInstance()->MigrateDatabase();

$pdo = DatabaseService::GetInstance()->GetDbConnectionRaw();
$rows = $pdo->query("SELECT COUNT(*) FROM users")->fetchColumn();
$stmt = $pdo->prepare("SELECT id, password FROM users WHERE username = 'admin'");
$stmt->execute();
$user = $stmt->fetch(PDO::FETCH_ASSOC);
if (empty($user)) {
    // The owner deleted or renamed the bootstrap account: acceptable only when other accounts exist.
    if ((int) $rows === 0) {
        fwrite(STDERR, "no users after the migration, refusing to start\n");
        exit(1);
    }
    echo "no account named admin, nothing to replace\n";
    exit(0);
}
if (!password_verify('admin', (string) $user['password'])) {
    echo "account admin has no default password, left unchanged\n";
    exit(0);
}
$upd = $pdo->prepare('UPDATE users SET password = ? WHERE id = ?');
if (!$upd->execute([password_hash($password, PASSWORD_ARGON2ID), $user['id']]) || $upd->rowCount() !== 1) {
    fwrite(STDERR, "could not update the password of admin\n");
    exit(1);
}
echo "default password of admin replaced\n";
