<?php

require_once('dbConnect.php');
require_once('class/class_dataDisplay.php');

$entry = new Entry_Display(22719, $conn, 'public');

var_dump($entry);

?>
