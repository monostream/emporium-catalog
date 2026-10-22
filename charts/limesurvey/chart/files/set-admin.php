<?php
// Runs after the entrypoint's database install/update and before Apache starts. Only when the
// administrator still has the throwaway password derived from the real one (that is, the entrypoint just
// installed the database) is the password replaced by the real one. Fails closed.
$real = (string) getenv('ADMIN_BOOTSTRAP_PASSWORD');
$tp = substr(hash_hmac('sha256', 'limesurvey-bootstrap', $real), 0, 32);
$user = (string) getenv('ADMIN_USER') ?: 'admin';
if ($real === '' || $tp === '') { fwrite(STDERR, "set-admin: missing password input\n"); exit(1); }
$dsn = sprintf('pgsql:host=%s;port=%s;dbname=%s', getenv('DB_HOST'), getenv('DB_PORT'), getenv('DB_NAME'));
$db = new PDO($dsn, getenv('DB_USERNAME'), getenv('DB_PASSWORD'), [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
$prefix = preg_replace('/[^A-Za-z0-9_]/', '', getenv('DB_TABLE_PREFIX') !== false ? trim(getenv('DB_TABLE_PREFIX')) : 'lime_');
if (getenv('DB_TABLE_PREFIX') === false) { $prefix = 'lime_'; }
$st = $db->prepare("SELECT uid, password FROM {$prefix}users WHERE users_name = ?");
$st->execute([$user]);
$row = $st->fetch(PDO::FETCH_ASSOC);
if (!$row) { fwrite(STDERR, "set-admin: administrator not found\n"); exit(1); }
if (password_verify($tp, $row['password'])) {
    $db->prepare("UPDATE {$prefix}users SET password = ? WHERE uid = ?")->execute([password_hash($real, PASSWORD_DEFAULT), $row['uid']]);
    echo "set-admin: administrator password set from the Secret\n";
} else {
    echo "set-admin: administrator already initialised\n";
}
