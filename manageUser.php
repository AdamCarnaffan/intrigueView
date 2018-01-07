<?php 

require_once('class/class_userData.php');
require_once('fixSession.php');
require_once('dbConnect.php');


$user = $_SESSION['user'];

if (!isset($user)) {
  // Log activities as a temporary user
  $user = new User($conn);
  $_SESSION['user'] = $user;
}

?>
