<?php
// auto_prepend_file for every web request. LimeSurvey (Yii) lets a request choose its controller
// route with the query parameter "r" even after a URL rule matched, which would bypass the Emporium
// login on the respondent prefixes. PHP normalises odd query names ("+r", "r.", "r ", "r%00", "%00r")
// into $_GET['r'], so the check is done here, after that normalisation, not on the raw query string.
if (PHP_SAPI === 'cli') { return; }
$deny = isset($_GET['r']) || isset($_REQUEST['r'])
    // PHP drops or truncates names with a NUL byte; no LimeSurvey URL needs one
    || stripos((string) ($_SERVER['QUERY_STRING'] ?? ''), '%00') !== false;
if (!$deny) {
    foreach (array_keys($_GET) as $k) {
        $k = strtolower(trim(str_replace("\0", '', (string) $k)));
        $k = preg_replace('/\s+/', '', $k);
        if ($k === 'r' || $k === '_r' || $k === 'r_') { $deny = true; break; }
    }
}
if (!$deny) {
    // "/r/<route>" path segments are read by Yii's path parser
    $path = rawurldecode(parse_url((string) ($_SERVER['REQUEST_URI'] ?? ''), PHP_URL_PATH) ?: '');
    foreach (explode('/', str_replace("\0", '', $path)) as $seg) {
        if (strtolower(trim($seg)) === 'r') { $deny = true; break; }
    }
}
if ($deny) {
    http_response_code(403);
    header('Content-Type: text/plain');
    echo "Forbidden\n";
    exit;
}
