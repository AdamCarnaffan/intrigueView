<?php
include('dbConnect.php');
include('objectConstruction.php');


$fileName = "pocketHTML/math.txt";
$feedId = 1;

$pocketContent = file_get_contents($fileName);

// Process and separate the URLs into an array
$breakIntoSections = explode('<img class="favicon lazy-active" data-originalurl=',$pocketContent);
// Remove the stuff before the first URL
array_shift($breakIntoSections);
$foundURLs = [];
// Process each URL into only the entry URL
foreach ($breakIntoSections as $singleURL) {
  $tempURL = explode('"',$singleURL)[1];
  // Trim the URL
  $trimmedURL = str_replace("https://getpocket.com/redirect?url=", "", $tempURL);
  $trimmedEnd = explode("&", $trimmedURL)[0];
  // Fix Characters
  // Fix the http colons
  $fixChars = str_replace('%3A', ':', $trimmedEnd);
  // Fix the /'s
  $fixChars = str_replace('%2F', "/", $fixChars);
  // Fix the &'s
  $urlFinal = str_replace('%26', "&", $fixChars);
  array_push($foundURLs, $urlFinal);
}

// Get all current URLs in the database at the Feed URL
$getAllCurrentURLs = "SELECT entry.url, entry.feed_id FROM feeds AS feed
                        JOIN entries AS entry ON feed.feed_id = entry.feed_id
                        WHERE feed.feed_id = '$feedId'";

// Build an array of current URLs for the feed
$currentURLs = [];
if ($result = $conn->query($getAllCurrentURLs)) {
  while ($row = $result->fetch_array()) {
    array_push($currentURLs, trim($row[0]));
  }
} else {
  throw new Exception("No connection could be made or the query is incorrect");
}

// Generate Feed and Summary Objects
$feedSelection = new FeedInfo($feedId, $conn);
$summary = new Summary();

// Create an Entry Object for each Entry that is unique
foreach ($foundURLs as $url) {
  if (!in_array($url, $currentURLs)) {
      // Get the site data as an object
      try {
        $entryInfo = new SiteData($url, $feedSelection->source, $conn);
      } catch (Exception $e) {
        $entryInfo->clearData();
        echo $e->getMessage() . " @ " . $item->link . "</br>";
      }
      // Fetch the title (usually done by pocket)
      $entryInfo->getTitle();
      // Format Date Time for mySQL
      $dateAdded = 0;
      // MySQL Statement
      $addEntry = "INSERT INTO `entries` (`feed_id`,`site_id`,`title`,`url`,`date_published`,`feature_image`,`preview_text`) VALUES ('$feedSelection->id','$entryInfo->siteId','$entryInfo->title','$url','$dateAdded','$entryInfo->imageURL','$entryInfo->synopsis')";
      if ($conn->query($addEntry)) { // Report all succcessful entries to the user
        $summary->entriesAdded++;
        array_push($summary->entriesList, $entryInfo->title);
      } else { // Keep a record of all failed additions
        $summary->entriesFailed++;
        array_push($summary->failuresList, $entryInfo->title);
        $summary->failureReason = $conn->error . " @ " . $item->link;
      }
    array_push($currentURLs, $url);
  }
}

?>
