<?php 

// Database information
$databaseLink = "localhost";
$dbUsername = "root";
$dbPassword = "root";
// Connection String Generation ("feed_collection" can be changed should it be edited in the database script)
$conn = new mysqli($databaseLink,$dbUsername,$dbPassword,"intrigue_view");

?>
