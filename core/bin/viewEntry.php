<?php
require_once('class/class_userData.php');
require_once('fixSession.php');
require_once('dbConnect.php');

// Add the view in the post

// $_POST['entry'] = 502;

$user = $_SESSION['user'];
$selectedEntry = (int)$_POST['entry'];

$conn->query("UPDATE entries SET views = views + 1 WHERE entryID = '$selectedEntry'");

// Add the view in the user

$user->view(new Entry($selectedEntry, $conn), $conn);
?>
