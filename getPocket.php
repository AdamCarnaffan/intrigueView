<?php 
include ('dbConnect.php');
include ('objectConstruction.php');


// Get the Source ID for database selection of feed
$sourceId = $_POST['sourceId'];
// The Export URL (RSS Feed) from getPocket
$feedSelection = new FeedInfo($sourceId, $conn);
// Time zone info to sync with feed
$timeZone = ('-5:00');

/*
RSS Feed xml attributes come from xml->[title][description][link]->attributes->ITEM PROPERTY
RSS Feed xml interpretation points xml->channel->LISTOFITEMS(item)->ITEM PROPERTY
*/

// Generate an XML object to represent the data collected
$xml = simplexml_load_file($feedSelection->source) or die("Error: Could not connect to the feed");

// Get the last update time (for comparison with any articles to add)
$getLastPub = "SELECT `date_published` FROM `entries` WHERE feed_id = '$feedSelection->id' ORDER BY `date_published` DESC LIMIT 1";

// Get the one data point in a single line and convert to a DateTime object
// GET TIMEZONE on insert (The data entering the database will be of the same timezone as that leaving the database) --> pocket doesn't offer this offset so matching is the best way
$lastUpdateValue = $conn->query($getLastPub)->fetch_array()[0];

if ($lastUpdateValue != null) {
  $lastUpdate = new DateTime($lastUpdateValue, new DateTimeZone($timeZone));
} else {
  $lastUpdate = new DateTime('0000-00-00 00:00:00');
}
// Entry tracking class Definition
$summary = new Summary();

// Check each Entry from bottom to top (Added chronologically)
for ($entryNumber = count($xml->channel->item) - 1; $entryNumber >= 0; $entryNumber--) {
  // Set the $item tag as is done in a foreach loop (Pathing from RSS Feed)
  $item = $xml->channel->item[$entryNumber];
  // Convert the Date to a DateTime Object
  $dateAdded = new DateTime($item->pubDate);
  // Check if the entry is a new addition to the pocket
  if ($dateAdded > $lastUpdate) {
    // Insert the item into the database
    // Filter title for SQL injection
    $filteredTitle = addslashes($item->title);
    // Get the site data as an object
    try {
      $entryInfo = new SiteData($item->link, $feedSelection->source, $conn);
    } catch (Exception $e) {
      $entryInfo->clearData();
      echo $e->getMessage() . " @ " . $item->link . "</br>";
    } 
    // Format Date Time for mySQL
    $dateAdded = $dateAdded->format('Y-m-d H:i:s');
    // MySQL Statement
    $addEntry = "INSERT INTO `entries` (`feed_id`,`site_id`,`title`,`url`,`date_published`,`feature_image`,`preview_text`) VALUES ('$feedSelection->id','$entryInfo->siteId','$filteredTitle','$item->link','$dateAdded','$entryInfo->imageURL','$entryInfo->synopsis')";
    if ($conn->query($addEntry)) { // Report all succcessful entries to the user
      $summary->entriesAdded++;
      array_push($summary->entriesList, $item->title);
    } else { // Keep a record of all failed additions
      $summary->entriesFailed++;
      array_push($summary->failuresList, $item->title);
      $summary->failureReason = $conn->error . " @ " . $item->link;
    }
  }
}

// Summary of Action
echo "<b>" . $summary->entriesAdded . " entries have been added to the database, including: </b></br>";
foreach ($summary->entriesList as $title) {
  echo $title . "</br>";
}
// Handle for failed actions report
if ($summary->entriesFailed > 0) {
  echo $summary->entriesFailed . " entries failed to be added to the database table due to: '" . $summary->failureReason . "'";
}

echo "hey";

return $summary; // To be returned to administrative page on a forced update



?>
