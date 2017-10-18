<?php
require('objectConstruction.php');

$username = $_POST['username'];
$password = $_POST['password'];
$email = $_POST['email'];

$username = "loller";
$password = "Laaaaaaaa1";
$email = "lol";


register($username, $password, $email);

function register($username, $password, $email) {
  // Create Query
  require('dbConnect.php');
  // Hash password
  $hashedPass = password_hash($password, PASSWORD_DEFAULT);

  $submitUser = "INSERT INTO users (username, password, email, default_submission_feed) VALUES ('$username', '$hashedPass', '$email', '1');
    SELECT LAST_INSERT_ID()";

  if (strlen($username) < 5) {
    echo "Your Username is too short";
    return;
  }
  if (strlen($password) < 9) {
    echo "Your Password must be at least 8 characters";
    return;
  }
  if (strlen($email) < 2) {
    echo "Your email address is invalid";
    return;
  }
  if (!preg_match("~[0-9]~", $password) || !preg_match("~[a-z A-Z]~", $password)) {
    echo "Your Password must contain a variation of letters and numbers";
    return;
  }
  if ($result = $conn->query($submitUser)) {
    $userId = $result->fetch_Array()[0]; //$conn->ID AUTO INCREMENT FIX
    $_SESSION['user'] = new User($userId, $conn, $username);
    header('location: admin/index.php');
  } elseif ($conn->error_no == 2) {
    echo "That username has already been taken";
    return;
  } else {
    echo $conn->error;
    echo "A Connection Error has occured";
    return;
  }
}



 ?>
