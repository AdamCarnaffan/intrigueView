<?php
include('dbConnect.php');
include('objectConstruction.php');
$url = "https://www.theguardian.com/science/2017/oct/18/its-able-to-create-knowledge-itself-google-unveils-ai-learns-all-on-its-own";

$tagBlackList = ['Top Image', 'Related Video', 'Know', 'Say', 'Default']; // This will be cached from the DB on a new fetch

$entry = new siteData($url, 7, $conn, $tagBlackList);

echo $entry->pageContent;

print_r($entry->tags);
?>
