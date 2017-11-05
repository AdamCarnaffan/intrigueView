<?php

$userID = $_POST['userID'];

$setAdmin = "INSERT INTO user_permissions (userID, permissionID) VALUES ('$userID', 8) ('$userID', 1) ('$userID', 3) ('$userID', 7)";

if ($conn->query($setAdmin)) {
  echo "Added Permission Successfully";
} else {
  echo $conn->error;
}

?>
