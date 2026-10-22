<?php
// Runs in an init container before Kanboard serves any request, and fails closed.
// Kanboard creates the account "admin" with the password "admin" when it migrates an
// empty database. This replaces that password with the one from ADMIN_PASSWORD.
// An account whose password is no longer "admin" (changed in the UI) is left alone.
require '/var/www/app/app/common.php'; // connects and migrates the database

$password = getenv('ADMIN_PASSWORD');
if ($password === false || strlen($password) < 8) {
    fwrite(STDERR, "ADMIN_PASSWORD is missing or shorter than 8 characters\n");
    exit(1);
}
if ($password === 'admin') {
    fwrite(STDERR, "ADMIN_PASSWORD must not be the default\n");
    exit(1);
}

$db = $container['db'];
$user = $db->table('users')->eq('username', 'admin')->findOne();
if (empty($user)) {
    // The owner deleted or renamed the bootstrap account: acceptable only when other accounts exist.
    if ($db->table('users')->count() === 0) {
        fwrite(STDERR, "no users after the migration, refusing to start\n");
        exit(1);
    }
    echo "no account named admin, nothing to replace\n";
    exit(0);
}
if (! password_verify('admin', (string) $user['password'])) {
    echo "account admin has no default password, left unchanged\n";
    exit(0);
}
$ok = $db->table('users')->eq('id', $user['id'])
    ->update(array('password' => password_hash($password, PASSWORD_BCRYPT)));
if (! $ok) {
    fwrite(STDERR, "could not update the password of admin\n");
    exit(1);
}
echo "default password of admin replaced\n";
