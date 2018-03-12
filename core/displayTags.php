<?php
require('dbConnect.php');

// $_POST['feeds'] = '2';

// Process Submitted Tags
$tags = $_POST['tags'];
$tagArray = explode('+', $tags);
$activeTags = implode("','",$tagArray);
// Process Submitted Feeds
$feeds = $_POST['feeds'];
$feedArray = explode('+', $feeds);
$activeFeeds = implode("','", $feedArray);

$popularTagCount = 20 - count($tagArray);

$getTags = "SELECT tags.tagID, tags.tagName, COUNT(DISTINCT tagConn.entryID) FROM entry_tags AS tagConn
	           JOIN tags ON tags.tagID = tagConn.tagID
             LEFT JOIN entry_connections AS entryConn ON entryConn.entryID = tagConn.entryID
             WHERE tags.tagID NOT IN ('$activeTags') AND entryConn.feedID IN ('$activeFeeds')
             GROUP BY tagConn.tagID
             ORDER BY COUNT(DISTINCT tagConn.entryID) DESC
             LIMIT $popularTagCount;
            SELECT tagID, tagName FROM tags WHERE tagID IN ('$activeTags') ORDER BY tagName";

// Fetch the tags
$conn->multi_query($getTags);
$popTags = $conn->store_result();
$conn->next_result();
$activeTagNames = $conn->store_result();
// Display Active Tags
while ($row = $activeTagNames->fetch_array()) {
  echo "<a class='filter-coloring tag no-underline active-tag' href='#' onclick='return removeTag(" . $row[0] . ")'>" . $row[1] . "</a>  ";
}
// Display Popular Tags
while ($row = $popTags->fetch_array()) {
  echo "<a class='filter-coloring tag no-underline' href='#' onclick='return addTag(" . $row[0] . ")'>" . $row[1] . '</a> ';
}

?>
