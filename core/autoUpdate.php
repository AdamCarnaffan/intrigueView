<?php
include_once('dbConnect.php');
// Select all pocket type feeds from the database
$getFeeds = "SELECT externalFeedID, url FROM external_feeds WHERE active = 1";

$rssFeeds = [];
$result = $conn->query($getFeeds);
while ($row = $result->fetch_array()) {
  array_push($rssFeeds, $row[0]);
}

foreach ($rssFeeds as $feed) {
  $_POST['sourceID'] = $feed;
  include('rssFetch.php');
}

 ?>
