<?php
// Runs in an init container before Kanboard serves any request.
// Kanboard creates the account admin/admin when it migrates an empty database.
// This replaces that password with the one from the ADMIN_PASSWORD environment
// variable. An account whose password is no longer "admin" (changed in the UI) is left alone.
require '/var/www/app/app/common.php'; // connects and migrates the database

$username = getenv('ADMIN_USERNAME') ?: 'admin';
$password = getenv('ADMIN_PASSWORD');
if ($password === false || strlen($password) < 8) {
    fwrite(STDERR, "ADMIN_PASSWORD is missing or shorter than 8 characters\n");
    exit(1);
}

$user = $container['db']->table('users')->eq('username', $username)->findOne();
if (empty($user)) {
    echo "account $username does not exist, nothing to do\n";
    exit(0);
}
if (! password_verify('admin', (string) $user['password'])) {
    echo "account $username has no default password, left unchanged\n";
    exit(0);
}
$ok = $container['db']->table('users')->eq('id', $user['id'])
    ->update(array('password' => password_hash($password, PASSWORD_BCRYPT)));
if (! $ok) {
    fwrite(STDERR, "could not update the password of $username\n");
    exit(1);
}
echo "default password of $username replaced\n";
