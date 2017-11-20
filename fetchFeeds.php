<?php
include('dbConnect.php');
include('objectConstruction.php');

$getFeeds = "SELECT feeds.sourceID, feeds.linkedBy, feeds.referenceTitle, feeds.feedImagePath, feeds.feedDescription FROM feeds
              LEFT JOIN user_feeds AS internal ON internal.internalFeedID = feeds.sourceID
              LEFT JOIN external_feeds AS external ON external.externalFeedID = feeds.sourceID
              WHERE internal.isPrivate = 0 OR feeds.isExternalFeed = 1 
              ORDER BY feeds.entryCount";

$feeds = $conn->query($getFeeds);

while ($feedData = $feeds->fetch_array()) {
  $feedDisplay = new FeedDisplay($feedData);
  echo $feedDisplay->generateTile();
}

?>
