<?php 

require_once('config.php');
require_once(ROOT_PATH . '/bin/dbConnect.php');
require_once(ROOT_PATH . '/class/class_dataFetch.php');

$url = "https://www.youtube.com/watch?v=EAJM5L9hhBs";

// Get tag blacklist
if (Tag_Potential::getBlackList() == null) {
  Tag_Potential::setBlackList($conn);
}

$entryInfo = new Entry_Data($url, $conn);

echo "</br>";
print_r($entryInfo->schema);

print_r($entryInfo->tags);

 ?>
