<?php

$dir = $_SERVER['DOCUMENT_ROOT'];

require("{$dir}/intrigueView/dbConnect.php");

$getAllPlurals = "SELECT tagName, tagID FROM tags WHERE tagName LIKE '%s'";

$sTagsQuery = $conn->query($getAllPlurals);

while ($tag = $sTagsQuery->fetch_array()) {
  $tempTag = new Tag($tag[0]);
  if ($tempTag->consolidate($conn)) {
    $purgePlural = "UPDATE entry_tags SET tagID = '$tempTag->databaseID' WHERE tagID = '$tag[1]'";
    $conn->query($purgePlural);
    $conn->query("DELETE FROM tags WHERE tagID = '$tag[1]'"); // Clean the tag from the database after removing its connections -> Plurals should not be added in future
  }
}
