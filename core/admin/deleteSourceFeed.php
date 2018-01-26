<?php 
include('../dbConnect.php');
include('../objectConstruction.php');
session_start();

$feedID = $_POST['sourceID'];

try {
  // Set the active status for the feed to 0
  $deleteFeed = "UPDATE external_feeds SET active = 0 WHERE externalFeedID = '$feedID'";
  if (!$conn->query($deleteFeed)) {
    throw new Exception($conn->error);
  }
} catch (Exception $e) {
  echo json_encode([
    'error' => [
        'msg' => $e->getMessage(),
        'code' => $e->getCode()
    ]
  ]);
}
 ?>
