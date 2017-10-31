<?php
include('dbConnect.php');
require('objectConstruction.php');


// Get the Source ID for database selection of feed
$sourceId = 6;
// The Export URL (RSS Feed) from getFeed
$feedSelection = new FeedInfo($sourceId, $conn);
// Time zone info to sync with feed
$timeZone = ('-5:00');
// Default for the error variable used in the loop
$error = false;

/*
RSS Feed xml attributes come from xml->[title][description][link]->attributes->ITEM PROPERTY
RSS Feed xml interpretation points xml->channel->LISTOFITEMS(item)->ITEM PROPERTY
*/

// Generate an XML object to represent the data collected
$xml = simplexml_load_file($feedSelection->source) or die("Error: Could not connect to the feed");

// Get the last update time (for comparison with any articles to add)
$getLastPub = "SELECT datePublished FROM entries JOIN entry_connections AS connections ON entries.entryID = connections.entryID WHERE connections.feedID = '$feedSelection->id' ORDER BY datePublished DESC LIMIT 1";

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
// Fetch the tag blacklist in preperation
$tagBlackList = ['Top Image', 'Related Video', 'Know', 'Say', 'Default']; // This will be cached from the DB on a new fetch

// Check each Entry from bottom to top (Added chronologically)
for ($entryNumber = count($xml->channel->item) - 1; $entryNumber >= 0; $entryNumber--) {
  // Set the $item tag as is done in a foreach loop (Pathing from RSS Feed)
  $item = $xml->channel->item[$entryNumber];
  // Convert the Date to a DateTime Object
  $dateAdded = new DateTime($item->pubDate);
  // Check if the entry is a new addition to the pocket
  if ($dateAdded > $lastUpdate) {
    // Insert the item into the database
    // Get the site data as an object
    try {
      $entryInfo = new SiteData($item->link, $feedSelection->source, $conn, $tagBlackList);
      // Check for title in RSS Feed, and fetch if not present
      if (isset($item->title)) {
        $entryInfo->title = $item->title;
      }
      // Filter title for SQL injection
      $entryInfo->title = addslashes($entryInfo->title);
    } catch (Exception $e) {
      $entryInfo = null;
      echo $e->getMessage() . " @ " . $item->link . "\n";
      $error = true;
      continue;
    }
    // Format Date Time for mySQL
    $dateAdded = $dateAdded->format('Y-m-d H:i:s');
    // MySQL Statement
    $addEntry = "CALL newEntry('$entryInfo->siteID','$feedSelection->id', '$entryInfo->title','$item->link','$dateAdded','$entryInfo->imageURL','$entryInfo->synopsis', @newID);
                  SELECT @newID";
    if ($conn->multi_query($addEntry)) { // Report all succcessful entries to the user
      // Cycle to second query
      $conn->next_result();
      $result = $conn->store_result();
      // Get the new entry's ID
      $entryID = $result->fetch_array()[0];
      // Add the tags with connections
      foreach ($entryInfo->tags as $sortOrder=>$tag) {
        $addTag = "CALL addTag('$tag', '$entryID', '$sortOrder')";
        $conn->query($addTag);
        echo $sortOrder . ") " . $tag . " added </br>";
      }
      $summary->entriesAdded++;
      array_push($summary->entriesList, $entryInfo->title);
    } elseif ($conn->errno == 1062) {
      // Make the Connection to the feed, instead of adding the entry
      $connectEntry = "CALL newEntryConnection('$item->link', '$feedSelection->id', @duplicate)";
      if ($conn->query($connectEntry)) {
        $summary->entriesAdded++;
        array_push($summary->entriesList, $entryInfo->title . " -- Duplicate Connected");
      } elseif ($conn->errno == 1048) {
        $summary->entriesFailed++;
        array_push($summary->failuresList, $entryInfo->title);
        $summary->failureReason = "The entry is not a duplicate but was treated as such" . " @ " . $item->link;
      } else {
        $summary->entriesFailed++;
        array_push($summary->failuresList, $entryInfo->title);
        $summary->failureReason = $conn->error . " @ " . $item->link;
      }
    } else { // Keep a record of all failed additions
      $summary->entriesFailed++;
      array_push($summary->failuresList, $entryInfo->title);
      $summary->failureReason = $conn->error . " @ " . $item->link;
    }
  } elseif ($error) {
    $error = false;
  }
	//echo $entryInfo->siteID . " " . $entryInfo->finalTitle . " " . $item->link . " " . $dateAdded . " " . $entryInfo->imageURL . " " . $entryInfo->synopsis . "</br></br>";
}

// Summary of Action
echo $summary->entriesAdded . " entries have been added to the database, including: \n";
foreach ($summary->entriesList as $title) {
  echo $title . "\n";
}
// Handle for failed actions report
if ($summary->entriesFailed > 0) {
  echo $summary->entriesFailed . " entries failed to be added to the database table due to: '" . $summary->failureReason . "'";
}

return $summary; // To be returned to administrative page on a forced update

?>
