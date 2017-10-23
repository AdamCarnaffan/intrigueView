<?php 
include('../dbConnect.php');
include('../objectConstruction.php');
session_start();

$feedId = $_POST['sourceId'];

try {
  // Set the active status for the feed to 0
  $deleteFeed = "UPDATE feeds SET active = 0 WHERE feedID = '$feedId'";
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
