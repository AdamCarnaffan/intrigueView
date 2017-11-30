<?php
require('dbConnect.php');
include('objectConstruction.php');
include('fixSession.php');

// $_POST['entryID'] = 20;

$user = $_SESSION['user'];
$targetFeed = $_POST['feedID'];

$checkDuplicate = "SELECT sourceFeed FROM feed_connections WHERE sourceFeed = '$targetFeed' AND internalFeed = '$user->feed'";

$duplicates = (count($conn->query($checkDuplicate)->fetch_array()) > 0) ? true : false;

if (!$duplicates) {
  $addConnection = "INSERT INTO feed_connections (sourceFeed, internalFeed, linkedBy) VALUES ('$targetFeed', '$user->feed', '$user->id')";
  $conn->query($addConnection);
} else {
  throw new Exception("This entry already exists in your feed");
}
?>
