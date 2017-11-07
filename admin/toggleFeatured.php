<?php 
include('../dbConnect.php');


$entryID = trim($_POST['entryID']);
$isFeatured = $_POST['isFeatured'];

if ($isFeatured === "true") {
  $changeFeature = "UPDATE entries SET featured = 0 WHERE entryID = '$entryID'";
} else {
  $changeFeature = "UPDATE entries SET featured = 1 WHERE entryID = '$entryID'";
}

$conn->query($changeFeature);

 ?>
