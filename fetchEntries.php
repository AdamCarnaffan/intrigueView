<?php
include('dbConnect.php');
require('objectConstruction.php');

// $_POST['selection'] = 10;
// $_POST['currentDisplay'] = 0;
// $_POST['tags'] = "";
// $_POST['tagMode'] = 0;
// $_POST['search'] = "AI";
// $_POST['feedsList'] = "2";
$_POST['context'] = "public";

// Take Inputs from the specific call
$selectedFeed = str_replace('+', ',', $_POST['feedsList']); // Currently Set to display Thompson's pocket in Featured
$selectionLimit = $_POST['selection'];
$selectionOffset = $_POST['currentDisplay'];
$searchKey = (isset($_POST['search']) && strlen($_POST['search']) > 0) ? $_POST['search'] : null;
$queryTags = $_POST['tags'];
$tagMode = $_POST['tagMode'];
$context = $_POST['context'];
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

// Check for feed access
$checkPrivate = "SELECT isPrivate, internalFeedID FROM user_feeds WHERE internalFeedID IN('$selectedFeed')";

$securityReturn = $conn->query($checkPrivate);
while ($secure = $securityReturn->fetch_array()) {
  if ($secure[0] == 1) {
    
  }
}

// Get Feed IDs of the origin feeds
$getFeeds = "SELECT sourceFeed FROM feed_connections WHERE internalFeed IN('$selectedFeed')";
$feedsListReturn = $conn->query($getFeeds);
// Break down the feed selection list
$selectedFeedArray = explode(',', $selectedFeed);
// add to the list
while ($row = $feedsListReturn->fetch_array()) {
  // Add all connected feeds to the selection list
  array_push($selectedFeedArray, $row[0]);
}
// Make sure the array does not have any duplicates
array_unique($selectedFeedArray);
// Consolidate the array for query
$selectedFeedList = implode("','", $selectedFeedArray);
// When changing the query, remember to adjust object
$getEntries = "SELECT entries.title, entries.url, entries.datePublished, entries.featureImage, entries.previewText, entries.featured, sites.url, sites.icon, entries.entryID, entries.visible, entryConn.feedID, entries.views FROM entries
	               JOIN sites ON entries.siteID = sites.siteID
                 JOIN entry_connections AS Entryconn ON entries.entryID = Entryconn.entryID
                 LEFT JOIN entry_tags AS tagConn ON tagConn.entryID = entries.entryID
                 LEFT JOIN tags ON tags.tagID = tagConn.tagID";
// Add the GROUP BY following all WHERE Statements
$getEntries .= " GROUP BY entries.entryID";
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
    $tempCondition = "SUM(CASE WHEN tagConn.tagID = '$tagID' THEN 1 ELSE 0 END) > 0";
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
  if ($addedTag) {
    $getEntries .= " AND BINARY entries.title LIKE '%$searchKey%'";
  } else {
    $getEntries .= " HAVING BINARY entries.title LIKE '%$searchKey%'";
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
    $tempCondition = "SUM(CASE WHEN tags.tagName = '$tagString' THEN 1 ELSE 0 END) > 0";
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

$getEntries .= "entries.visible = 1 AND
                SUM(CASE WHEN entryConn.feedID IN('$selectedFeedList') THEN 1 ELSE 0 END) > 0
                ORDER BY entryConn.dateConnected DESC, entries.entryID ASC
                LIMIT $selectionLimit OFFSET $selectionOffset";
// Prepare and query
$entriesFound = false;
$display = [];
$entries = $conn->query($getEntries);
// echo $conn->error;
// echo "</br>";
// echo $getEntries;
while ($row = $entries->fetch_array()) {
  $entryIDVal = $row[8];
  $getTags = "SELECT tagConn.entryID, tags.tagNAME, tags.tagID FROM entry_tags AS tagConn
              JOIN tags ON tags.tagID = tagConn.tagID
              WHERE tagConn.entryID = '$entryIDVal'
              ORDER BY sortORDER LIMIT 3"; // Only get the first 3 tags for the entry
  $tags = $conn->query($getTags);
  $entry = new Entry($row, $tags, $context);
  $tempTile = $entry->displayEntryTile($entryDisplayNumber, $features);
  array_push($display, $tempTile);
  $entryDisplayNumber++;
  $entriesFound = true;
}
if (!$entriesFound && ($search == true || $tagged == true)) {
  array_push($display, "<h4>No Entries were found matching the provided parameters.</h4>");
} elseif (!$entriesFound) {
  array_push($display, "<h4>This Feed does not have any entries yet. Check out the <a href='feedBuilder.php'>Feed Builder</a> to find out how to add your own!</h4>");
}
$finalDisplay = implode($display);
$fullQuery = ($entryDisplayNumber-1 == $selectionLimit) ? 'true' : 'false';
$totalData = ['display'=>$finalDisplay, 'isFull'=>$fullQuery];
echo json_encode($totalData);
 ?>
