<?php
require_once(ROOT_PATH . '/class/class_userData.php');
require_once(ROOT_PATH . '/bin/fixSession.php');
require_once(ROOT_PATH . '/bin/dbConnect.php');

if (!isset($_SESSION['user'])) {
  // Log activities as a temporary user
  $user = new User($conn);
  $_SESSION['user'] = $user;
} else {
  $user = $_SESSION['user'];
}

?>
