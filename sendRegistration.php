<?php
require('objectConstruction.php');

$username = $_POST['username'];
$password = $_POST['password'];
$email = $_POST['email'];

$password = "Laaaaaaaa1";
$email = "lol";


register($username, $password, $email);

function register($username, $password, $email) {
  // Create Query
  require('dbConnect.php');
  // Hash password
  $hashedPass = password_hash($password, PASSWORD_DEFAULT);

  $submitUser = "CALL createUser('$username', '$hashedPass', '$email', @out_userID);
                  SELECT @out_userID;";

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
  if ($conn->multi_query($submitUser)) {
    $userId = $conn->store_result()->fetch_array()[0]; //$conn->ID AUTO INCREMENT FIX
    $_SESSION['user'] = new User($userId, $conn, $username);
    header('location: admin/index.php');
  } elseif ($conn->errno == 1062) {
    echo $conn->error;
    echo "That username is already in use";
    return;
  } else {
    echo $conn->error;
    //echo "A Connection Error has occured";
    return;
  }
}



 ?>
