<?php 
include('dbConnect.php');
include('objectConstruction.php');

$validationError = "The username or password entered was incorrect";
$inputUsername = $_POST['username'];
$inputPassword = $_POST['password'];

$userQuery = "SELECT user_id, password, username FROM users WHERE username = ? AND active = 1";

if ($getUser = $conn->prepare($userQuery)) {
	$getUser->bind_param('s', $inputUsername);
} else {
	throw new Exception($conn->error);
}

if ($getUser->execute()) {
  $row = $getUser->get_result()->fetch_array();
  if (count($row) > 0) {
    $userId = $row[0];
    $dbPass = $row[1];
    $username = $row[2];
    if (password_verify($inputPassword, $dbPass)) {
      session_start();
      $_SESSION['user'] = new User($userId, $conn, $username);
      echo "<script>window.location = 'admin/'</script>";
    } else {
      echo $validationError;
    }
  } else {
    echo $validationError;
  }
} else {
  echo "A connection error occured";
}


// CREATE A USER OBJECT AND INCLUDE OBJECTS IN ALL PAGES

 ?>
