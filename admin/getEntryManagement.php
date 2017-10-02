<?php 
include('../dbConnect.php');
include('../objectConstruction.php');
// Create a Data Table row for each entry to be displayed
$feedId = $_POST['feedId'];

$getEntries = "SELECT entry_id, title, feature_image, featured FROM entries WHERE visible = 1 AND feed_id = '$feedId' ORDER BY entry_id DESC";

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
