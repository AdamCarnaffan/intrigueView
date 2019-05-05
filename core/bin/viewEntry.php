<?php
require_once('../config.php');
require_once(ROOT_PATH . '/bin/dbConnect.php');
require_once(ROOT_PATH . '/class/class_userData.php');

// Add the view in the post

// $_POST['entry'] = 502;

$user = $_SESSION['user'];
$selectedEntry = (int)$_POST['entry'];

$conn->query("INSERT INTO user_views (user_id, entry_id) VALUES ({$user->id}, $selectedEntry)");

// Add the view in the user

// $user->view(new Entry($selectedEntry, $conn), $conn);
?>
