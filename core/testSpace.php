<?php

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

require_once('dbConnect.php');
include($cfg->rootDirectory . 'debug.php');

$conn->query("UPDATE external_feeds SET (active) = (0) WHERE title = 'Migration Feed'");

?>
