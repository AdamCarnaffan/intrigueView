<?php
include('dbConnect.php');

$_POST['entry'] = 502;

$selectedEntry = $_POST['entry'];

$viewEntry = "UPDATE entries SET views = views + 1 WHERE entryID = '$selectedEntry'";

$conn->query($viewEntry);

?>
