<?php 
include('../dbConnect.php');


$entryId = trim($_POST['entryId']);

$deleteEntry = "UPDATE entries SET visible = 0 WHERE entryID = '$entryId'";

$conn->query($deleteEntry);

 ?>
