<?php 

require_once('config.php');
require_once(ROOT_PATH . '/bin/dbConnect.php');
require_once(ROOT_PATH . '/class/class_dataFetch.php');

$url = "https://photography.tutsplus.com/articles/100-free-photoshop-actions-and-how-to-make-your-own--photo-3502";

// Get tag blacklist
if (Tag_Potential::getBlackList() == null) {
  Tag_Potential::setBlackList($conn);
}

$entryInfo = new Entry_Data($url, $conn);

$entryInfo->source->getPageIcon($entryInfo);

echo $entryInfo->source->icon . "</br>";

print_r($entryInfo->meta);

 ?>
