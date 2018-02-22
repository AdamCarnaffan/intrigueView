<?php 

require_once('\core\dbConnect.php');

$getAllEntries = "SELECT entryID FROM entries";

$result = $conn->query($getAllEntries);

while ($id = $result->fetch_array()[0]) {
  $_POST['target'] = "entry_{$id}";
  include('\core\entryFetch.php');
}

?>
