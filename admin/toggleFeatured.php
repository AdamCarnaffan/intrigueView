<?php 
include('../dbConnect.php');


$entryId = trim($_POST['entryId']);
$isFeatured = $_POST['isFeatured'];

if ($isFeatured === "true") {
  $changeFeature = "UPDATE entries SET featured = 0 WHERE entry_id = '$entryId'";
} else {
  $changeFeature = "UPDATE entries SET featured = 1 WHERE entry_id = '$entryId'";
}

$conn->query($changeFeature);

 ?>
