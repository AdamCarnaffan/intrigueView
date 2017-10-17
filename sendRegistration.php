<?php
require('dbConnect.php');
require('objectConstruction.php');

$username = $_POST['username'];
$password = $_POST['password'];
$email = $_POST['email'];

register($username, $password, $email);

function register($username, $password, $email) {
  if (strlen($username) < 5) {
    echo "Your Username is too short";
    return;
  }
  if (strlen($password) < 9) {
    echo "Your Password must be at least 8 characters";
    return;
  }
  if (!preg_match("~[0-9]~", $password) || !preg_match("~[a-z A-Z]~", $password) {
    echo "Your Password must contain a variation of letters and numbers";
    return;
  }
  if ($conn->query($submitUser)) {

  } else {
    echo "A Connection Error has occured";
    return;
  }
}



 ?>
