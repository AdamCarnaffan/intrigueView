<?php 
include('dbConnect.php');
include('objectConstruction.php');

$selectionLimit = $_POST['selection'];
$selectionOffset = $_POST['currentDisplay'];
$entryDisplayNumber = $selectionOffset + 1; // The slot for page display (all queries return an even number of slots used)
// When changing the query, remember to adjust object 
$getEntries = "SELECT feed.title, entries.title, entries.url, entries.date_published, entries.feature_image, entries.preview_text, site.url, site.icon FROM `entries` JOIN `feeds` AS feed ON entries.feed_id = feed.feed_id JOIN `sites` AS site ON entries.site_id = site.site_id ORDER BY `date_published` DESC LIMIT $selectionLimit OFFSET $selectionOffset";
$result = $conn->query($getEntries);
while ($row = $result->fetch_array()) {
  $entry = new Entry($row, $entryDisplayNumber);
  if ($entry->isFeature()) {
    $entryDisplayNumber++; // Feature entries consume two slots
  }
  $entryDisplayNumber++;
}

 ?>
