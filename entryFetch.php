<?php
include_once('dbConnect.php');
require('objectConstruction.php');

$_POST['targetID'] = 25;
$_POST['url'] = "https://www.wired.com/2017/12/geeks-guide-last-jedi/";

$targetFeed = $_POST['targetID'];
$targetURL = $_POST['url'];

// Time zone info to sync with feed
$timeZone = ('-5:00');
// Default for the error variable used in the loop
$error = false;
// Entry tracking class Definition
$summary = new Summary();

// Fetch the tag blacklist in preperation
$getBlackList = "SELECT blacklistedTag FROM tag_blacklist";
$result = $conn->query($getBlackList);
$tagBlackList = []; // Initialize the array
while ($row = $result->fetch_array()) {
  // add each tag to the array
  array_push($tagBlackList, $row[0]);
}

// Insert the item into the database
// Get the site data as an object

try {
  // Remove the /amp from site links where applicable
  if (strpos($targetURL, "wired.com") !== false || strpos($targetURL, "engadget.com") !== false) {
    // remove amp at the end of the URL
    if (strpos($targetURL, "/amp") == strlen($targetURL) - 4) {
      $targetURL = str_replace("/amp", "", $targetURL);
    }
    // Replace an amp in the middle with a single slash
    $targetURL = str_replace("/amp/", "/", $targetURL);
  }
  $entryInfo = new Entry_Data($targetURL, $targetFeed, $conn, $tagBlackList);
  // Filter text for SQL injection
  $entryInfo->title = $conn->real_escape_string($entryInfo->title);
  $entryInfo->synopsis = $conn->real_escape_string($entryInfo->synopsis);
} catch (Exception $e) {
  $entryInfo = null;
  echo $e->getMessage() . " @ " . $targetURL . "\n";
  $error = true;
  exit;
}
foreach ($entryInfo->tags as $sortOrder=>$tag) {
  echo $sortOrder . ") " . $tag . " added </br>";
}
// Format Date Time for mySQL
$dateAdded = new DateTime();
$dateAdded = $dateAdded->format('Y-m-d H:i:s');
// MySQL Statement
$addEntry = "CALL newEntry('$entryInfo->siteID', '$targetFeed', '$entryInfo->title','$targetURL','$dateAdded','$entryInfo->imageURL','$entryInfo->synopsis', @newID);
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
    //echo $sortOrder . ") " . $tag . " added </br>";
  }
  $summary->entriesAdded++;
  array_push($summary->entriesList, $entryInfo->title);
} elseif ($conn->errno == 1062) {
  // Make the Connection to the feed, instead of adding the entry
  $connectEntry = "CALL newEntryConnection('$targetURL', '$targetFeed', @duplicate)";
  if ($conn->query($connectEntry)) {
    $summary->entriesAdded++;
    array_push($summary->entriesList, $entryInfo->title . " -- Duplicate Connected");
  } elseif ($conn->errno == 1048) {
    $summary->entriesFailed++;
    array_push($summary->failuresList, $entryInfo->title);
    $summary->failureReason = "The entry is not a duplicate but was treated as such @ " . $targetURL;
  } else {
    $summary->entriesFailed++;
    array_push($summary->failuresList, $entryInfo->title);
    $summary->failureReason = $conn->error . " @ " . $targetURL;
  }
} else { // Keep a record of all failed additions
  $summary->entriesFailed++;
  array_push($summary->failuresList, $entryInfo->title);
  $summary->failureReason = $conn->error . " @ " . $targetURL;
}

// Summary of Action
echo $summary->entriesAdded . " entries have been added to the database, including: \n";
foreach ($summary->entriesList as $title) {
  echo $title . "\n";
}
// Handle for failed actions report
if ($summary->entriesFailed > 0) {
  echo "\n {$summary->entriesFailed} entries failed to be added to the database table due to: '{$summary->failureReason}' ";
}

?>
