<?php
include('dbConnect.php');
require('objectConstruction.php');

// $_POST['selection'] = 10;
// $_POST['currentDisplay'] = 0;
// $_POST['tags'] = [];
// $_POST['tagMode'] = 0;

// Take Inputs from the specific call
$selectedFeed = 3; // Currently Set to display Thompson's pocket in Featured
$selectionLimit = $_POST['selection'];
$selectionOffset = $_POST['currentDisplay'];
$searchKey = (isset($_POST['search']) && strlen($_POST['search']) > 0) ? $_POST['search'] : null;
$queryTags = $_POST['tags'];
$tagMode = $_POST['tagMode'];

// Set default values
$entryDisplayNumber = 1; // The slot for page display in a given set
$features = [1];
$tiles = $selectionLimit; // Assumes all are single tiles
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
/* QUERY EXAMPLE
SELECT entries.entryID, entries.title, entries.url, entries.datePublished, entries.featureImage, entries.previewText, entries.featured, sites.url, sites.icon FROM entries
	               JOIN sites ON entries.siteID = sites.siteID
                 LEFT JOIN entry_tags AS tagConn ON tagConn.entryID = entries.entryID
                 LEFT JOIN tags ON tagConn.tagID = tags.tagID
                 WHERE entries.visible = 1
                 GROUP BY entries.entryID
				 HAVING SUM(CASE WHEN tags.tagID = 1 THEN 1 ELSE 0 END) = 1
         AND SUM(CASE WHEN tags.tagID = 2 THEN 1 ELSE 0 END) = 1
         AND SUM(CASE WHEN tags.tagID = 3 THEN 1 ELSE 0 END) = 1
*/

// When changing the query, remember to adjust object
$getEntries = "SELECT entries.title, entries.url, entries.datePublished, entries.featureImage, entries.previewText, entries.featured, sites.url, sites.icon, entries.entryID, entries.visible, conn.feedID FROM entries
	               JOIN sites ON entries.siteID = sites.siteID
                 JOIN entry_connections AS conn ON entries.entryID = conn.entryID
                 LEFT JOIN entry_tags AS tagConn ON tagConn.entryID = entries.entryID
                 LEFT JOIN tags ON tagConn.tagID = tags.tagID";
// Adjust the query if a search is present
$search = false;
if ($searchKey != null && strlen($searchKey) > 0) {
 $getEntries .= " AND entries.title LIKE '%$searchKey%'";
 $search = true;
}
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
    $tempCondition = "SUM(CASE WHEN tags.tagID = '$tagID' THEN 1 ELSE 0 END) = 1";
    if (!$addedTag) {
      $getEntries .= " HAVING " . $tempCondition;
      // Only the first tag condition is first
      $addedTag = true;
    } else {
      $getEntries .= $tagQueryMode . $tempCondition;
    }
  }
}
if (!$addedTag) {
  $getEntries .= " HAVING ";
} else {
  $getEntries .= " AND ";
}

// Finish the query

$getEntries .= "entries.visible = 1 AND conn.feedID = '$selectedFeed'
                ORDER BY entries.datePublished DESC, entries.entryID ASC
                LIMIT $selectionLimit OFFSET $selectionOffset";
// Prepare and query
$entriesFound = false;
$display = [];
$entries = $conn->query($getEntries);
echo $conn->error;
while ($row = $entries->fetch_array()) {
  $entryIDVal = $row[8];
  $getTags = "SELECT tagConn.entryID, tags.tagNAME, tags.tagID FROM entry_tags AS tagConn
              JOIN tags ON tags.tagID = tagConn.tagID
              WHERE tagConn.entryID = '$entryIDVal'
              ORDER BY sortORDER LIMIT 4"; // Only get the first 4 tags for the entry
  $tags = $conn->query($getTags);
  $entry = new Entry($row, $tags);
  $tempTile = $entry->displayEntryTile($entryDisplayNumber, $features);
  array_push($display, $tempTile);
  $entryDisplayNumber++;
  $entriesFound = true;
}
if (!$entriesFound && ($search == true || $tagged == true)) {
  array_push($display, "<h2>No Entries were found matching the provided parameters.</h2>");
} elseif (!$entriesFound) {
  array_push($display, "<h2>This Feed does not have any entries yet.</h2>");
}
$finalDisplay = implode($display);
$fullQuery = ($entryDisplayNumber-1 == $selectionLimit) ? 'true' : 'false';
$totalData = ['display'=>$finalDisplay, 'isFull'=>$fullQuery];
echo json_encode($totalData);
 ?>
