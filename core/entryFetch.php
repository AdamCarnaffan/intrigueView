<?php
require_once('dbConnect.php');
require_once('class/class_dataFetch.php');

// $_POST['target'] = "entry_7"; // The target Feed to save to
$_POST['url'] = "";
$_POST['method'] = 1;

/*
*   METHOD INDEX
*   1 -> Manual testing (PHP)
*   2 -> Forced (Javascript)
*   3 -> Automation (PHP -> unattended)
*/

$target = $_POST['target'];
$method = $_POST['method'];

// Determine the action
if (strpos($target, "entry") !== false) {
  // Use entry refetch
  $targetEntry = str_replace("entry_", "", $target);
  $targetURL = $conn->query("SELECT url FROM entries WHERE entryID = '$targetEntry' LIMIT 1")->fetch_array()[0];
  $newEntry = false;
} else if (strpos($target, "feed") !== false) {
  // Use a target feed and url to get a new article
  // Check that the url string exists
  if (!isset($_POST['url'])) {
    throw new Exception("A URL is required to fetch a new entry");
  }
  // Set the target URL to the string
  $targetURL = $_POST['url'];
  $targetFeed = str_replace("feed_", "", $target);
  $newEntry = true;
} else {
  // echo "The target selection '{$target}' is invalid! Please specify 'entry_#' OR 'feed_#'";
  throw new Exception("No valid target set. '{$target}' should be formatted as either 'entry_#' or 'feed_#'");
}

// Time zone info to sync with feeding
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
  $entryInfo = new Entry_Data($targetURL, $conn, $tagBlackList);
  if ($newEntry) {
    // Format Date Time for mySQL
    $dateAdded = new DateTime();
    $dateAdded = $dateAdded->format('Y-m-d H:i:s');
    // Submit the entry and receive the result
    $result = $entryInfo->submitEntry($conn, $targetFeed, $dateAdded) . $lineEnding;
  } else {
    $previousEntryData = $conn->query("SELECT url, title, featureImage, siteID, entryID, previewText FROM entries WHERE entryID = '$targetEntry' LIMIT 1")->fetch_array();
    $prevEntry = new Entry($previousEntryData, $conn);
    $prevEntry->updateEntry($entryInfo, $conn);
    $result = "The entry '{$prevEntry->title}' has been updated {$lineEnding}";
  }
} catch (Exception $e) {
  $entryInfo = null;
  echo $e->getMessage() . " in '" . $targetURL . "' {$lineEnding}";
  $error = true;
  exit;
}

if ($logReport) {
  // Designate and load a file
  $logTarget = "entryLog.txt";
  try {
    $file = fopen($logTarget, 'a');
  } catch (Exception $fileException) {}
  // Write to the log file
  if (isset($file)) {
    fwrite($file, $result);
  }
} else {
  echo $result;
}

// Throw a file write exception if needed
if (isset($fileException)) {
  throw new Exception ($fileException->getMessage());
}

?>
