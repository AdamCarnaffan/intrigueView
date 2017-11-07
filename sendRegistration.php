<?php
require('objectConstruction.php');

$username = $_POST['username'];
$password = $_POST['password'];
$email = $_POST['email'];

register($username, $password, $email);

function register($username, $password, $email) {
  // Create Query
  require('dbConnect.php');

  // Username must be at least 5 characters
  if (strlen($username) < 5) {
    echo "Your Username is too short";
    return;
  }
  // Username must not include any illegal characters
  if (preg_match("~^[\p{P}]~", $username)) {
    echo "The username may not include any punctuation";
    return;
  }
  // Password must be at least 8 characters
  if (strlen($password) < 8) {
    echo "Your Password must be at least 8 characters";
    return;
  }
  // No email address is less than 2 characters
  if (strlen($email) < 2) {
    echo "Your email address is invalid";
    return;
  }
  // a password needs at least 1 number and 1 capital or lowercase letter
  if (!preg_match("~[0-9]~", $password) || !preg_match("~[a-z A-Z]~", $password)) {
    echo "Your Password must contain letters and numbers";
    return;
  }

  // Build Query

  // Hash password
  $hashedPass = password_hash($password, PASSWORD_DEFAULT);

  // Escape Values
  $username = $conn->real_escape_string($username);
  $email = $conn->real_escape_string($email);

  $submitUser = "CALL createUser('$username', '$hashedPass', '$email', @out_userID);
                  SELECT @out_userID;";

  if ($conn->multi_query($submitUser)) {
    // Move to second line query (SELECT ID)
    $conn->next_result();
    // Get ID
    $userId = $conn->store_result()->fetch_row()[0];
    // Begin a session and insert user data
    include('fixSession.php');
    $_SESSION['user'] = new User($userId, $conn, $username);
    // Navigate to the home screen, now logged in
    echo "<script>window.location = 'index.php'</script>";
    return;
  } elseif ($conn->errno == 1062) { // Duplicate submission to a unique field error code
    //echo $conn->error;
    echo "That username is already in use";
    return;
  } else {
    //echo $conn->error;
    echo "A Connection Error has occured";
    return;
  }
}



 ?>