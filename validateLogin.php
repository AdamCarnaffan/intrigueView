<?php 
include('dbConnect.php');
include('objectConstruction.php');

$validationError = "The username or password entered was incorrect";
$inputUsername = $_POST['username'];
$inputPassword = $_POST['password'];

$getUser = $conn->prepare("SELECT user_id, password FROM users WHERE username = ? AND active = 1");
$getUser->bind_param('s', $inputUsername);

if ($getUser->execute()) {
  $row = $getUser->get_result()->fetch_array();
  if (count($row) > 0) {
    $userId = $row[0];
    $dbPass = $row[1];
    if (password_verify($inputPassword, $dbPass)) {
      session_start();
      $_SESSION['user'] = new User($userId, $conn);
      echo "<script>window.location = 'adminConsole.php'</script>";
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
