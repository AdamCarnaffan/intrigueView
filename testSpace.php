<?php 

class Item {
  
  public $link;
  
  public function __construct() {}  
}

$item = new Item;

$item->link = "https://wired.com/story/hackers-say-broke-face-id-security/amp";

// Remove the /amp from site links where applicable
if (strpos($item->link, "wired.com") !== false || strpos($item->link, "engadget.com") !== false) {
  // remove amp at the end of the URL
  if (strpos($item->link, "/amp") == strlen($item->link) - 4) {
    $item->link = str_replace("/amp", "", $item->link);
  }
  // Replace an amp in the middle with a single slash
  $item->link = str_replace("/amp/", "/", $item->link);
}

echo $item->link;

?>
