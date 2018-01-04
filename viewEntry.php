<?php
include('fixSession.php');
include('dbConnect.php');
require_once('class_userData.php');

// Add the view in the post

$_POST['entry'] = 502;

$selectedEntry = $_POST['entry'];

$viewEntry = "UPDATE entries SET views = views + 1 WHERE entryID = '$selectedEntry'";

$conn->query($viewEntry);

// Add the view in the user

$user->view($conn);

?>
