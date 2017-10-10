<?php 
include ('dbConnect.php');
// Select all pcoket type feeds from the database
$getFeeds = "SELECT feed_id, url FROM feeds WHERE active = 1";

$result = $conn->query($getFeeds);
while ($row = $result->fetch_array()) {
  if ($row[1] != null) {
    array_push($pocketFeeds, $row[0]);
  }
}

foreach ($pocketFeeds as $feed) {
  $_POST['sourceId'] = $feed;
  include('getPocket.php');
}

 ?>
