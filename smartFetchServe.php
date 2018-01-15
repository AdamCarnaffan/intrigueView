<?php 
require_once('dbConnect.php');

$getRelevantTags = "SELECT tagName, (CASE WHEN entries.datePublished BETWEEN DATE_ADD(NOW(), INTERVAL -1 DAY) AND NOW() THEN 0 ELSE 1 END) AS recentAdd FROM tags 
                      JOIN entry_tags AS tagConn ON tags.tagID = tagConn.tagID
                      JOIN entries ON tagConn.entryID = entries.entryID
                      GROUP BY tags.tagID
                      ORDER BY recentAdd, COUNT(tags.tagID) DESC LIMIT 70";

$getNewTags = $conn->query($getRelevantTags);

while ($tag = $getNewTags->fetch_array()) {
  $_POST['searchString'] = $tag;
  include('smartFetch.php');
}

?>
