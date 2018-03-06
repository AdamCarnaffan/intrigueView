<?php

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

require_once('dbConnect.php');
include($cfg->rootDirectory . 'debug.php');

// $conn->query("DELETE FROM entries WHERE entryID IN(SELECT entrie.entryID FROM (SELECT * FROM entries) AS entrie JOIN entry_connections AS en ON en.entryID = entrie.entryID WHERE en.feedID = 2) AND datePublished > DATE('2018-02-25')");
// 
// echo $conn->error;
$getLastPub = "SELECT datePublished, entries.title FROM entries JOIN entry_connections AS connections ON entries.entryID = connections.entryID WHERE feedID = '2' ORDER BY connections.dateConnected DESC LIMIT 1";

$timeZone = ('-5:00');

$res = $conn->query($getLastPub)->fetch_array();

$lastUpdateValue = $res[0];
echo "Entry is -> {$res[1]} </br>";

$lastUpdate = new DateTime($lastUpdateValue, new DateTimeZone($timeZone));

$xml = simplexml_load_file('https://getpocket.com/users/*sso14832800504759bc/feed/all') or die("Error: Could not connect to the feed");

for ($entryNumber = count($xml->channel->item) - 1; $entryNumber >= 0; $entryNumber--) {
  $item = $xml->channel->item[$entryNumber];
  // Convert the Date to a DateTime Object
  $dateAdded = new DateTime($item->pubDate);
  $interval = $lastUpdate->diff($dateAdded);
  $change = $interval->format('%R%a');
  echo "{$lastUpdate->format('Y-m-d H:i:s')} TO {$dateAdded->format('Y-m-d H:i:s')} INT $change </br>";
}

?>
