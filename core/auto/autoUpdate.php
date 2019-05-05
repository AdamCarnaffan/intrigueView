<?php
require_once('../config.php');
require_once(ROOT_PATH . '/bin/dbConnect.php');

// Select all external feeds from the database
$getFeeds = "SELECT feed_id FROM feeds WHERE active = 1";

$rssFeeds = [];
$result = $conn->query($getFeeds);
while ($row = $result->fetch_array()) {
  $rssFeeds[] = $row[0];
}

foreach ($rssFeeds as $feed) {
  $_POST['sourceID'] = $feed;
  include(ROOT_PATH . '/auto/rssFetch.php');
}

 ?>
