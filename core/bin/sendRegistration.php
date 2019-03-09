<?php
require_once('../config.php');
require_once(ROOT_PATH . '/class/class_userData.php');
require('dbConnect.php');

// NEEDS TO INCORPORATE PRELOGIN DATA

$username = $_POST['username'];
$password = $_POST['password'];
$email = $_POST['email'];

register($username, $password, $email);

function register($username, $password, $email) {
  // Build Query

  // Hash password
  $hashedPass = password_hash($password, PASSWORD_DEFAULT);

  // Escape Values
  $username = $conn->real_escape_string($username);
  $email = $conn->real_escape_string($email);

  $submitUser = "CALL createUser('$username', '$hashedPass', '$email', @out_userID);
                  SELECT username, userFeedID, userID FROM users WHERE userID = @out_userID;";

  if ($conn->multi_query($submitUser)) {
    // Move to second line query (SELECT ID)
    $conn->next_result();
    // Get DataPackage for User Construction
    $data = $conn->store_result()->fetch_row();
    $dataPackage['id'] = $data[2];
    $dataPackage['username'] = $data[0];
    $dataPackage['feedID'] = $data[1];
    // Begin a session and insert user data
    include('fixSession.php');
    $_SESSION['user'] = new User($dataPackage, $conn);
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
