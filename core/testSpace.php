<?php 
include("dbConnect.php");
include("class/class_dataFetch.php");

$new = new Entry_Data("https://www.wired.com/story/sonoss-ipo-filing-shows-risks-of-relying-on-amazon-and-apple/", $conn);

var_dump($new);

?>
