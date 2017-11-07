<?php 
include('../dbConnect.php');
include('../objectConstruction.php');
// Create a Data Table row for each entry to be displayed
$feedID = $_POST['feedID'];

$getEntries = "SELECT entries.entryID, entries.title, entries.featureImage, entries.featured, conn.feedID FROM entries 
              LEFT JOIN entry_connections AS conn ON conn.entryID = entries.entryID
              WHERE entries.visible = 1 AND conn.feedID = '$feedID' ORDER BY entryID DESC";

// Generate table rows for each Entry
if ($result = $conn->query($getEntries)) {
  while ($row = $result->fetch_array()) {
    echo "<tr>";
    // Image Column
    echo "<td><img class='sample' src='" . $row[2] . "'></td>";
    // Title Column
    echo "<td><h4>" . $row[1] . "</h4></td>";
    // Buttons Column
    echo "<td>";
    // Determine Feature Tag 
    $featureTag = ($row[3] == 1) ? 'entry-feature' : null;
    echo "<button class='" . $featureTag . "' id='deleteEntry_" . $row[0] . "' onclick='toggleFeatureEntry(this, " . $row[0] . ")'>Feature</button>";
    echo "<button id='deleteEntry_" . $row[0] . "' onclick='deleteEntry(this, " . $row[0] . ")'>Delete</button>";
    echo "</td>";
    echo "</tr>";
  }
}
echo "</table>";

 ?>
