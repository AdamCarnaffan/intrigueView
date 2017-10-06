<?php
include('dbConnect.php');
include('objectConstruction.php');

$selectionLimit = $_POST['selection'];
$selectionOffset = $_POST['currentDisplay'];
$searchKey = (isset($_POST['search']) && strlen($_POST['search']) > 0) ? $_POST['search'] : null;
$entryDisplayNumber = 1; // The slot for page display in a given set
$features = [1];
$tiles = $selectionLimit; // Assumes all are single tiles
// Calculate features array
for ($c = 1; $c <= round($selectionLimit / 25); $c++) { // Number of feature cycles
  array_push($features, $c*19);
  array_push($features, $c*11);
}
$tiles += count($features);
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
// When changing the query, remember to adjust object
$getEntries = "SELECT feed.title, entries.title, entries.url, entries.date_published, entries.feature_image, entries.preview_text, entries.featured, site.url, site.icon FROM `entries`
                  JOIN `feeds` AS feed ON entries.feed_id = feed.feed_id
                  JOIN `sites` AS site ON entries.site_id = site.site_id
                  WHERE entries.visible = 1
                  ORDER BY entries.date_published DESC, entries.entry_id ASC
                  LIMIT $selectionLimit OFFSET $selectionOffset";
// Adjust the query if a search is present
$search = false;
if ($searchKey != null && strlen($searchKey) > 0) {
  $getEntries = substr_replace($getEntries, " AND entries.title LIKE '%$searchKey%'", 361 ,1);
  $search = true;
}
// Prepare and query
$entriesFound = false;
$display = [];
$result = $conn->query($getEntries);
while ($row = $result->fetch_array()) {
  $entry = new Entry($row);
  $tempTile = $entry->displayEntryTile($entryDisplayNumber, $features);
  array_push($display, $tempTile);
  $entryDisplayNumber++;
  $entriesFound = true;
}
if (!$entriesFound && $search == true) {
  arrya_push($display, "<h2>No Entries were found matching the provided parameters.</h2>");
}
$finalDisplay = implode($display);
$fullQuery = ($entryDisplayNumber-1 == $selectionLimit) ? 'true' : 'false';
$totalData = ['display'=>$finalDisplay, 'isFull'=>$fullQuery];
echo json_encode($totalData);
 ?>
