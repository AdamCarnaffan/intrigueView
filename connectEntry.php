<?php
require('dbConnect.php');
include('objectConstruction.php');
include('fixSession.php');

// $_POST['entryID'] = 20;

$user = $_SESSION['user'];
$targetEntry = $_POST['entryID'];

$checkDuplicate = "SELECT connectionID FROM entry_connections WHERE entryID = '$targetEntry' AND feedID = '$user->feed'";

$duplicates = (count($conn->query($checkDuplicate)->fetch_array()) > 0) ? true : false;

if (!$duplicates) {
  $addConnection = "INSERT INTO entry_connections (entryID, feedID, linkedBy) VALUES ('$targetEntry', '$user->feed', '$user->id')";
  $conn->query($addConnection);
} else {
  throw new Exception("This entry already exists in your feed");
}
?>
