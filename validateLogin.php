<?php
include('dbConnect.php');
require('objectConstruction.php');

$validationError = "The username or password entered was incorrect";
$inputUsername = $_POST['username'];
$inputPassword = $_POST['password'];

$userQuery = "SELECT userID, password, username, userFeedID FROM users WHERE username = ? AND active = 1";

if ($getUser = $conn->prepare($userQuery)) {
	$getUser->bind_param('s', $inputUsername);
} else {
	throw new Exception($conn->error);
}

if ($getUser->execute()) {
  $row = $getUser->get_result()->fetch_array();
  if (count($row) > 0) {
    $dataPackage['id'] = $row[0];
    $dbPass = $row[1];
    $dataPackage['username'] = $row[2];
		$dataPackage['feedID'] = $row[3];
     if (password_verify($inputPassword, $dbPass)) {
			include('fixSession.php');
      $_SESSION['user'] = new User($dataPackage, $conn);
      echo "<script>window.location = 'index.php'</script>";
			exit;
    } else {
      echo $validationError;
    }
  } else {
    echo $validationError;
  }
} else {
  echo "A connection error occured";
}

 ?>
