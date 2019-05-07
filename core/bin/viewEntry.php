<?php
require_once('../config.php');
require_once(ROOT_PATH . '/bin/dbConnect.php');
require_once(ROOT_PATH . '/class/class_userData.php');
require_once(ROOT_PATH . '/bin/fixSession.php');

// Add the view in the post

// $_POST['entry'] = 32;

$user = $_SESSION['user'];
$selectedEntry = (int)$_POST['entry'];

// Handle completely unvisited case
if ($user == null || $user->isTemp) {
  $idStr = 'NULL';
} else {
  $idStr = $user->id;
}

$conn->query("INSERT INTO user_views (user_id, entry_id) VALUES ($idStr, '$selectedEntry')");

// Add the view in the user

// $user->view(new Entry($selectedEntry, $conn), $conn);
?>
