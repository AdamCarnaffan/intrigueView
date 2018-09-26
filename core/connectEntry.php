<?php
require_once('ManageUser.php');

// $_POST['entryID'] = 1090;

$user = $_SESSION['user'];
$targetEntry = $_POST['entryID'];

$checkDuplicate = "SELECT connectionID FROM entry_connections WHERE entryID = '$targetEntry' AND feedID = '$user->feed'";

$duplicates = (count($conn->query($checkDuplicate)->fetch_array()) > 0) ? true : false;

if (!$duplicates) {
  $addConnection = "INSERT INTO entry_connections (entryID, feedID) VALUES ('$targetEntry', '$user->feed')";
  $conn->query($addConnection);
} else {
  throw new Exception("This entry already exists in your feed");
}
?>
