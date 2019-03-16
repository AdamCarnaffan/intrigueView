<?php 
require_once('../config.php');
require_once(ROOT_PATH . '/bin/dbConnect.php');
require_once(ROOT_PATH . '/class/class_dataFetch.php');

$_POST['entry_id'] = 27; // Select entry to re-fetch

$selectedEntry = $_POST['entry_id'];

$entry = new Entry($selectedEntry, $conn);

// Get tag blacklist
if (Tag_Potential::getBlackList() == null) {
  Tag_Potential::setBlackList($conn);
}

$entryInfo = new Entry_Data($entry->url, $conn);
// Filter text for SQL injection
$entry->updateEntry($entryInfo, $conn);

 ?>
