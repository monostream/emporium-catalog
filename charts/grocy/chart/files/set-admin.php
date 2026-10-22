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
