<?php
include_once('dbConnect.php');
require_once('objectConstruction.php');

/*
*   METHOD INDEX
*   1 -> Manual testing (PHP)
*   2 -> Forced (Javascript)
*   3 -> Automation (PHP -> unattended)
*/

$_POST['sourceID'] = 2;
$_POST['method'] = 1;

// Get the Source ID for database selection of feed
$sourceID = $_POST['sourceID'];
$method = $_POST['method'];
// IMPERSONATION FOR MIGRATION
//$feedSudoID = 6;
// The Export URL (RSS Feed)
$feedSelection = new FeedInfo($sourceID, $conn, 1);

if ($feedSelection->busy) {
  echo "The feed is currently being fetched and as such is unavailable";
  return;
} elseif ($feedSelection->isExternal) {
  $busyFeed = "UPDATE external_feeds SET busy = 1 WHERE externalFeedID = '$feedSelection->id'";
  $conn->query($busyFeed);
}
// Time zone info to sync with DB from feed common
$timeZone = ('-5:00');
// Default for the error variable used in the loop
$error = false;

// Use query method to determine reporting methodology
$logReport = false;

if ($method == 1) {
  $lineEnding = "</br>";
} else if ($method == 2) {
  $lineEnding = "\n";
} else {
  $lineEnding = "\r\n";
  $logReport = true;
}

// Define a shutdown function
register_shutdown_function(function() use ($feedSelection) {
  include('dbConnect.php');
  $unloadFeed = "UPDATE external_feeds SET busy = 0 WHERE externalFeedID = '$feedSelection->id'";
  $conn->query($unloadFeed);
});

/*
RSS Feed xml attributes come from xml->[title][description][link]->attributes->ITEM PROPERTY
RSS Feed xml interpretation points xml->channel->LISTOFITEMS(item)->ITEM PROPERTY
*/

// Impersonation for Sudo ID migration
if (isset($feedSudoID)) {
  $feedSelection->id = $feedSudoID;
}

// Generate an XML object to represent the data collected
$xml = simplexml_load_file($feedSelection->source) or die("Error: Could not connect to the feed");

// Get the last update time (for comparison with any articles to add)
$getLastPub = "SELECT datePublished FROM entries JOIN entry_connections AS connections ON entries.entryID = connections.entryID WHERE feedID = '$feedSelection->id' ORDER BY connections.dateConnected DESC LIMIT 1";

// Get the one data point in a single line and convert to a DateTime object
// GET TIMEZONE on insert (The data entering the database will be of the same timezone as that leaving the database) --> pocket doesn't offer this offset so matching is the best way
$lastUpdateValue = $conn->query($getLastPub)->fetch_array()[0];

if ($lastUpdateValue != null) {
  $lastUpdate = new DateTime($lastUpdateValue, new DateTimeZone($timeZone));
} else {
  $lastUpdate = new DateTime('0000-00-00 00:00:00');
}
// Entry Submission result tracker
$results = [];

// Fetch the tag blacklist in preperation
$getBlackList = "SELECT blacklistedTag FROM tag_blacklist";
$result = $conn->query($getBlackList);
$tagBlackList = []; // Initialize the array
while ($row = $result->fetch_array()) {
  // add each tag to the array
  array_push($tagBlackList, $row[0]);
}
// Check each Entry from bottom to top (Added chronologically)
for ($entryNumber = count($xml->channel->item) - 1; $entryNumber >= 0; $entryNumber--) {
  // Set the $item tag as is done in a foreach loop (Pathing from RSS Feed)
  $item = $xml->channel->item[$entryNumber];
  // Convert the Date to a DateTime Object
  $dateAdded = new DateTime($item->pubDate);
  $interval = $lastUpdate->diff($dateAdded);
  $change = $interval->format('%R%a');
  //$dateAdded > $lastUpdate
  // Check if the entry is a new addition to the feed
  if ($change > 0) {
    // Format Date Time for mySQL
    $dateAdded = $dateAdded->format('Y-m-d H:i:s');
    echo $dateAdded . " -> " . $lastUpdate->format('Y-m-d H:i:s') . "</br>";
    // Get the site data as an object
    try {
      // Remove the /amp from site links where applicable
      if (strpos($item->link, "wired.com") !== false || strpos($item->link, "engadget.com") !== false) {
        // remove amp at the end of the URL
        if (strpos($item->link, "/amp") == strlen($item->link) - 4) {
          $item->link = str_replace("/amp", "", $item->link);
        }
        // Replace an amp in the middle with a single slash
        $item->link = str_replace("/amp/", "/", $item->link);
      }
      $entryInfo = new Entry_Data($item->link, $conn, $tagBlackList);
      // Check for title in RSS Feed, and fetch if not present
      if (isset($item->title)) {
        $entryInfo->title = $item->title;
      }
      // Filter text for SQL injection
      $submissionResult = $entryInfo->submitEntry($conn, $feedSelection->id, $dateAdded) . " {$lineEnding}";
      array_push($results, $submissionResult);
    } catch (Exception $e) {
      unset($entryInfo);
      $submissionResult = "{$e->getMessage()} occured on URL '{$item->link}' {$lineEnding}";
      array_push($results, $submissionResult);
      $error = true;
      continue;
    }
  }
}

if ($logReport) {
  // Designate and load a file
  $logTarget = "entryLog.txt";
  try {
    $file = fopen($logTarget, 'a');
  } catch (Exception $fileException) {}
  // Write to the log file
  if (isset($file)) {
    foreach ($results as $entryData) {
      fwrite($file, $entryData);
    }
  }
} else {
  if (count($results) > 0) {
    // Display the report
    foreach ($results as $line) {
      echo $line;
    }
  } else {
    echo "Feed ID {$feedSelection->id} is up to date at this time {$lineEnding}";
  }
}

if ($feedSelection->isExternal) {
  $releaseFeed = "UPDATE external_feeds SET busy = 0 WHERE externalFeedID = '$feedSelection->id'";
  $conn->query($releaseFeed);
}

// Throw a file write exception if needed
if (isset($fileException)) {
  throw new Exception ($fileException->getMessage());
}

?>
