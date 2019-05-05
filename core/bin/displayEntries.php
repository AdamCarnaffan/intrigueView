<?php
ini_set('display_errors', '0');

require_once('../config.php');
require_once(ROOT_PATH . '/bin/dbConnect.php');
require_once(ROOT_PATH . '/class/class_dataDisplay.php');
require_once(ROOT_PATH . '/bin/manageUser.php');

$_POST['selection'] = 100;
$_POST['currentDisplay'] = 0;
$_POST['tags'] = "";
$_POST['tagMode'] = 0;
$_POST['search'] = "";
$_POST['feedsList'] = "1";
$_POST['recommend'] = true;
// $_POST['context'] = "public";

// Take Inputs from the specific call
$selectedFeed = str_replace('+', ',', $_POST['feedsList']); // Currently Set to display Thompson's pocket in Featured
$selectionLimit = $_POST['selection'];
$selectionOffset = $_POST['currentDisplay'];
$searchKey = (isset($_POST['search']) && strlen($_POST['search']) > 0) ? $_POST['search'] : null;
$queryTags = $_POST['tags'];
$tagMode = $_POST['tagMode'];
$showRecommended = ($_POST['recommend'] == "true") ? true : false;
// $context = $_POST['context'];

// Generate search as tags as well
$searchTags = (strlen($searchKey) > 1) ? explode(" ", $searchKey) : [];
$search = false;

// Set default values
$entryDisplayNumber = 1; // The slot for page display in a given set
$features = [1];
$tiles = $selectionLimit; // Assumes all are single tiles
$tagged = false;
// Calculate features array
for ($c = 1; $c <= round($selectionLimit / 25); $c++) { // Number of feature cycles
  array_push($features, $c*19);
  array_push($features, $c*11);
}
$tiles += count($features); // Make the total count of display tiles include the double tiles
if (0 != $currentFeatureOffset = $tiles % 4) {
  for ($c = 1; $c <= (4 - $currentFeatureOffset); $c++) {
    if (isset($features[$c])) {
      $addedFeature = floor(($features[$c-1] + $features[$c]) / 2);
    } else {
      $addedFeature = $c + 1;
    }
    array_push($features, $addedFeature);
    $tiles++;
  }
}
$pos = 0; // Position in the features array
// Verify that each feature can be a feature --> subtract one if not
foreach ($features as $feature) {
  // Calculate the number of features before it
  $features[$pos] = -7; // Set the current feature id to an impossible value
  $prevFeatures = 0;
  foreach ($features as $val) {
    if ($val < $feature && $val > 0) {
      $prevFeatures++;
    }
  }
  // Check that no two features are the same
  if (in_array($feature, $features)) {
    $feature--;
  }
  // Make a final prediction of the tile location for the feature
  $predictedTile = $feature + $prevFeatures;
  // Diminish feature position if it falls on the outer edge
  if ($predictedTile % 4 == 0) {
    $feature--;
    if (in_array($feature, $features)) {
      $feature--;
    }
  }
  // Set the feature to resume its position in the features array
  $features[$pos] = $feature;
  // move to the next position in the array
  $pos++;
}

// // Get Feed IDs of the origin feeds
// $getFeeds = "SELECT sourceFeed FROM feed_connections WHERE internalFeed IN('$selectedFeed')";
// $feedsListReturn = $conn->query($getFeeds);
// // Break down the feed selection list
$selectedFeedArray = explode(',', $selectedFeed);
// // add to the list
// while ($row = $feedsListReturn->fetch_array()) {
//   // Add all connected feeds to the selection list
//   array_push($selectedFeedArray, $row[0]);
// }
// Make sure the array does not have any duplicates
array_unique($selectedFeedArray);
// Consolidate the array for query
$selectedFeedList = implode("','", $selectedFeedArray);
// When changing the query, remember to adjust object
$getEntries = "SELECT entries.title, entries.url, entries.published, entries.thumbnail, entries.synopsis, entries.site_id, entries.entry_id, entries.visible, entryConn.feed_id FROM entries
                 JOIN feed_entries AS entryConn ON entries.entry_id = entryConn.entry_id
                 LEFT JOIN entry_tags AS tagConn ON tagConn.entry_id = entries.entry_id
                 LEFT JOIN tags ON tags.tag_id = tagConn.tag_id
                 WHERE entryConn.feed_id IN ('$selectedFeedList')"; // Removed a segment in the large conditional
// Add the GROUP BY following all WHERE Statements
$getEntries .= " GROUP BY entries.entry_id";
// Add the Tag Query
$addedTag = false;
if ($queryTags != "" && $queryTags != null) {
  $tagged = true;
  // Determine query mode
  if ($tagMode == 1) {
    $tagQueryMode = " AND ";
  } else {
    $tagQueryMode = " OR ";
  }
  $tags = explode("+", $queryTags);
  foreach ($tags as $tagID) {
    $tempCondition = "SUM(CASE WHEN tagConn.tag_id = '$tagID' THEN 1 ELSE 0 END) > 0";
    if (!$addedTag) {
      $getEntries .= " HAVING " . $tempCondition;
      // Only the first tag condition is first
      $addedTag = true;
    } else {
      $getEntries .= $tagQueryMode . $tempCondition;
    }
  }
}
// Adjust the query if a search is present
if ($searchKey != null && strlen($searchKey) > 0) {
  // Create an adjusted string where the first letter is capitalized or not (based on original)
  $splitSearch = str_split($searchKey);
  $splitSearch[0] = (ctype_upper($splitSearch[0])) ? strtolower($splitSearch[0]) : strtoupper($splitSearch[0]);
  $adjustedSearchKey = implode($splitSearch);
  // Add the search string to the query
  if ($addedTag) {
    $getEntries .= " AND (BINARY entries.title LIKE '%$searchKey%' OR BINARY entries.title LIKE '%$adjustedSearchKey%')";
  } else {
    $getEntries .= " HAVING (BINARY entries.title LIKE '%$searchKey%' OR BINARY entries.title LIKE '%$adjustedSearchKey%')";
  }
 $search = true;
}
if (count($searchTags) > 0) {
  if ($addedTag) {
    $condition = " AND ";
  } else {
    $condition = " OR ";
  }
  foreach ($searchTags as $tagString) {
    $tempCondition = "SUM(CASE WHEN tags.tag = '$tagString' THEN 1 ELSE 0 END) > 0";
    $getEntries .= $condition . $tempCondition;
  }
  $addedTag = true;
}
if (!$addedTag) {
  $getEntries .= " HAVING ";
} else {
  $getEntries .= " AND ";
}

// Finish the query
$selectEntriesValue = $showRecommended ? $selectionLimit - (floor($selectionLimit / 10)) : $selectionLimit;

$getEntries .= "entries.visible = 1
                ORDER BY entryConn.connected DESC, entries.published DESC
                LIMIT $selectEntriesValue OFFSET $selectionOffset";
// Prepare and query
$entriesFound = false;
$display = [];
$recomNumber = 0;
$entries = $conn->query($getEntries);
// echo $conn->error;
// echo "</br>";
// echo $getEntries;
while ($row = $entries->fetch_array()) {
  $entry = new Entry_Display($row, $conn);
  $tempTile = $entry->displayEntryTile($entryDisplayNumber, $features);
  array_push($display, $tempTile);
  $entryDisplayNumber++;
  if ($showRecommended && $entryDisplayNumber % 10 == 0) {
    $addEntry = true;
    try {
      do {
        if (count($user->recommendations) == 0 || $recomNumber >= count($user->recommendations)) {
          $prevRecom = $user->recommendations;
          $user->generateRecommendations($conn);
          $recomNumber = 0;
          if (count($user->recommendations) == 0 || $prevRecom == $user->recommendations) {
            break;
          }
        }
        // print_r($user->recommendations);
        // echo "</br>";
        // Check that the recommendation is not being displayed in this feed
        $checkRecom = "SELECT entry_id FROM feed_entries AS entryConn
                        WHERE feed_id IN ('$selectedFeedList') AND entry_id = '{$user->recommendations[$recomNumber]}'";
        if (!$conn->query($checkRecom)->fetch_array()) {
          // echo $user->recommendations[$recomNumber];
          $entry = new Entry_Display($user->recommendations[$recomNumber], $conn);
          $tempTile = $entry->displayEntryTile($entryDisplayNumber, $features);
          array_push($display, $tempTile);
          $entryDisplayNumber++;
          $addEntry = false;
          // Remove the recommended from the display array
          unset($user->recommendations[$recomNumber]);
          $user->recommendations = array_values($user->recommendations);
        }
        $recomNumber++;
      } while ($addEntry);
    } catch (Exception $error) {
      //echo $error;
    }
  }
  $entriesFound = true;
}
if (!$entriesFound && ($search == true || $tagged == true)) {
  array_push($display, "<h4>No Entries were found matching the provided parameters.</h4>");
} elseif (!$entriesFound) {
  array_push($display, "<h4>This Feed does not have any entries yet. Check out the <a href='feedBuilder.php'>Feed Builder</a> to find out how to add your own!</h4>");
}
$finalDisplay = implode($display);
$fullQuery = ($entryDisplayNumber-1 >= $selectionLimit) ? 'true' : 'false';
$totalData = ['display'=>$finalDisplay, 'isFull'=>$fullQuery];
echo json_encode($totalData);
 ?>
