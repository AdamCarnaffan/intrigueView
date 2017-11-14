<?php
include('../dbConnect.php');

$userID = $_POST['userID'];

$setAdmin = "INSERT INTO user_permissions (userID, permissionID) VALUES ('$userID', 1), ('$userID', 2), ('$userID', 3), ('$userID', 4), ('$userID', 7), ('$userID', 8)";

if ($conn->query($setAdmin)) {
  echo "Added Permission Successfully";
} else {
  echo $conn->error;
}

?>
