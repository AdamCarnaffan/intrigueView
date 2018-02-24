<?php
require_once('dbConnect.php');
require_once('class/class_dataDisplay.php');

$getFeeds = "SELECT feeds.sourceID, feeds.linkedBy, feeds.referenceTitle, feeds.feedImagePath, feeds.feedDescription FROM feeds
              LEFT JOIN user_feeds AS internal ON internal.internalFeedID = feeds.sourceID
              LEFT JOIN external_feeds AS external ON external.externalFeedID = feeds.sourceID
              WHERE internal.isPrivate = 0 OR feeds.isExternalFeed = 1";

if ($feeds = $conn->query($getFeeds)) {
  while ($feedData = $feeds->fetch_array()) {
    $feedDisplay = new Feed_Display($feedData, $conn);
    echo $feedDisplay->generateTile();
  }
} else {
  echo "<h4>An error occured while querying the feeds</h4>";
}




?>
