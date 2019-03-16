<?php
require_once('../config.php');
require_once(ROOT_PATH . '/bin/dbConnect.php');
require_once(ROOT_PATH . '/class/class_dataFetch.php');

$_POST['sourceID'] = 1;


// Get the Source ID for database selection of feed
$sourceID = $_POST['sourceID'];
$expectShutdown = false;
// IMPERSONATION FOR MIGRATION
// $feedSudoID = 6;

// LOG -> Began to fetch a feed
$conn->multi_query("CALL startFetchLog('$sourceID', @fetchSess); SELECT @fetchSess;");
$conn->next_result();
$fetchSession = $conn->store_result()->fetch_array()[0];

try {
  $feedSelection = new Feed($sourceID, $conn);
} catch (exception $e) {
  // LOG -> Feed fetch failed on connection error
  $logErr = "Failed to access feed data";
  $conn->query("INSERT INTO fetch_log (fetch_id, feed_id, status, success) VALUES ('$fetchSession', '$sourceID', '$logErr', 0)");
  return;
}

// Check if the feed is busy
if ($feedSelection->checkBusy($conn)) {
  // LOG -> Feed busy
  $logErr = "The Feed is currently busy with another fetch (record_lock)";
  $conn->query("INSERT INTO fetch_log (fetch_id, feed_id, status, success) VALUES ('$fetchSession', '$sourceID', '$logErr', 0)");
  return;
}

// Attempt to record lock the feed
try {
  //$feedSelection->lock($conn);
} catch (exception $e) {
  // LOG -> Couldn't lock feed
  $logErr = "Failed to lock the feed";
  $conn->query("INSERT INTO fetch_log (fetch_id, feed_id, status, success) VALUES ('$fetchSession', '$sourceID', '$logErr', 0)");
  return;
}

// Define a shutdown function
register_shutdown_function(function() use ($feedSelection, $fetchSession, $conn, $expectShutdown) {
  try {
    $feedSelection->release($conn);
    // LOG -> shutdown time
    if (!$expectShutdown) {
      $logErr = "Encountered an unexpected shutdown";
      $succ = 0;
      $conn->query("INSERT INTO fetch_log (fetch_id, feed_id, status, success) VALUES ('$fetchSession', '$feedSelection->id', '$logErr', 0)");
    }
  } catch (exception $e) {
    // LOG -> Release lock failed
    $logErr = "Releasing record lock failed on: {$e}";
    $conn->query("INSERT INTO fetch_log (fetch_id, feed_id, status, success) VALUES ('$fetchSession', '$feedSelection->id', '$logErr', 0)");

  }
  });

// Time zone info to sync with DB from feed common
$timeZone = ('-5:00');
// Default for the status variables in logging
$error = false;
$entriesAdded = 0;

/*
RSS Feed xml attributes come from xml->[title][description][link]->attributes->ITEM PROPERTY
RSS Feed xml interpretation points xml->channel->LISTOFITEMS(item)->ITEM PROPERTY
*/

// Impersonation for Sudo ID migration
if (isset($feedSudoID)) {
  $feedSelection->id = $feedSudoID;
}

// Generate an XML object to represent the data collected
try {
  $xml = $feedSelection->fetchXML();
} catch (exception $e) {
  // LOG -> Failed to get XML data
  $logErr = "Failed to get XML data from feed";
  $conn->query("INSERT INTO fetch_log (fetch_id, feed_id, status, success) VALUES ('$fetchSession', '$sourceID', '$logErr', 0)");
  return;
}

// Get tag blacklist
if (Tag_Potential::getBlackList() == null) {
  Tag_Potential::setBlackList($conn);
}

// Cycle each possible entry source
for ($entryNumber = count($xml->channel->item) - 1; $entryNumber >= 0; $entryNumber--) {
  // echo "</br> LAST ERROR: " . $conn->error;
  // Set the $item tag as is done in a foreach loop (Pathing from RSS Feed)
  $item = $xml->channel->item[$entryNumber];
  // Convert the Date to a DateTime Object
  $dateAdded = new DateTime($item->pubDate);
  // Remove the /amp from site links where applicable (this process should be generalized)
  if (strpos($item->link, "wired.com") !== false || strpos($item->link, "engadget.com") !== false) {
    // remove amp at the end of the URL
    if (strpos($item->link, "/amp") == strlen($item->link) - 4) {
      $item->link = str_replace("/amp", "", $item->link);
    }
    // Replace an amp in the middle with a single slash
    $item->link = str_replace("/amp/", "/", $item->link);
  }
  // Check if the entry is a new addition to the feed
  if (!Entry_Data::doesExist($item->link, $feedSelection->id, $conn)) {
    // Format Date Time for mySQL
    $dateAdded = $dateAdded->format('Y-m-d H:i:s');
    // Get the site data as an object
    try {
      $entryInfo = new Entry_Data($item->link, $conn);
      // Check for title in RSS Feed, and fetch if not present
      if (isset($item->title)) {
        $entryInfo->title = $item->title;
      }
      $entryInfo->submitEntry($conn, $feedSelection->id, $dateAdded);
      // LOG -> Entry added to db successfully
      $logErr = "Adding the entry succeeded";
      $conn->query("INSERT INTO entry_log (entry_id, status, success) VALUES ('$entryInfo->id', '$logErr', 0)");
      $entriesAdded++;
    } catch (Exception $e) {
      // LOG -> Exception with getting entry data or submitting
      $logErr = $conn->real_escape_string("Adding the entry to the database failed on url: {$item->link} by -> {$e}");
      $conn->query("INSERT INTO entry_log (entry_id, status, success) VALUES (NULL, '$logErr', 0)");
      $error = true;
      unset($entryInfo);
      continue;
    }
    unset($entryInfo);
  }
}

if (!$error) {
  // LOG -> Success with feed fetch (Added {NUMBER} entries)
  $res = "Fetching feed successful: " . $entriesAdded . " entries added";
  $conn->query("INSERT INTO fetch_log (fetch_id, feed_id, status, success) VALUES ('$fetchSession', '$sourceID', '$res', 1)");
} else {
  // LOG -> Feed fetch finished with some errors
  $logErr = "Feed fetch complete with entry errors: " . $entriesAdded . " entries added";
  $conn->query("INSERT INTO fetch_log (fetch_id, feed_id, status, success) VALUES ('$fetchSession', '$sourceID', '$logErr', 0)");
}

$expectShutdown = true;

?>
