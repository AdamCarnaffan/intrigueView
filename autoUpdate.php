<?php 
include('dbConnect.php');
// Select all pcoket type feeds from the database
$getFeeds = "SELECT externalFeedID, url FROM external_feeds WHERE active = 1";

$rssFeeds = [];
$result = $conn->query($getFeeds);
while ($row = $result->fetch_array()) {
  array_push($rssFeeds, $row[0]);
}

foreach ($rssFeeds as $feed) {
  $_POST['sourceId'] = $feed;
  include('rssFetch.php');
}

 ?>
