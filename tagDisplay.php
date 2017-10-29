<?php
require('dbConnect.php');

// Process Submitted Tags
$tags = $_POST['tags'];
$tagArray = explode('+', $tags);
$activeTags = implode("','",$tagArray);

$popularTagCount = 30 - count($tagArray);

$getTags = "SELECT tags.tagID, tags.tagName, COUNT(tagConn.entryID) FROM entry_tags AS tagConn
              JOIN tags ON tags.tagID = tagConn.tagID
              WHERE tags.tagID NOT IN ('$activeTags')
              GROUP BY tags.tagID
              ORDER BY COUNT(tagConn.entryID) DESC
              LIMIT $popularTagCount;
            SELECT tagID, tagName FROM tags WHERE tagID IN ('$activeTags') ORDER BY tagName";

// Fetch the tags
$conn->multi_query($getTags);
$popTags = $conn->store_result();
$conn->next_result();
$activeTagNames = $conn->store_result();
// Display Active Tags
while ($row = $activeTagNames->fetch_array()) {
  echo "<a class='filter-coloring tag no-underline active-tag' href='#' onclick='return removeTag(" . $row[0] . ")'>" . $row[1] . "</a> ";
}
// Display Popular Tags
while ($row = $popTags->fetch_array()) {
  echo "<a class='filter-coloring tag no-underline' href='#' onclick='return addTag(" . $row[0] . ")'>" . $row[1] . '(' . $row[2] . ')</a> ';
}

?>
