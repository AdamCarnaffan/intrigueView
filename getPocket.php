<?php 
//Testing feedId Definition
$_POST['feedId'] = 1;

// Summary Class Definition (for calling the page as an instantaneous update return)
class Summary {
  
  public $entriesAdded = 0;
  public $entriesList = [];
  public $entriesFailed;
  public $failuresList = [];
  public $failureReason;
  
  public function __construct() {}
  
}

class FeedInfo {
  
  public $title;
  public $source;
  public $id;
  
  public function __construct($feedId, $dbConn) {
    $this->id = $feedId;
    $sourceQuery = "SELECT `feed_title`, `feed_url` FROM `feed_sources` WHERE `feed_source_id` = '$this->id'";
    if ($result = $dbConn->query($sourceQuery)) {
      $sourceInfo = $result->fetch_array();
    } else {
      throw new exception($conn->error);
    }
    $this->title = $sourceInfo['feed_title'];
    $this->source = $sourceInfo['feed_url'];
  }
  
}

// Database information
$databaseLink = "localhost";
$dbUsername = "root";
$dbPassword = "root";
// Connection String Generation ("feed_collection" can be changed should it be edited in the database script)
$conn = new mysqli($databaseLink,$dbUsername,$dbPassword,"feed_collection");

// Get the Source ID for database selection of feed
$sourceId = $_POST['feedId'];
// The Export URL (RSS Feed) from getPocket
$feedSelection = new FeedInfo($sourceId, $conn);
// Time zone info to sync with feed
$timeZone = ('-5:00');


/*
RSS Feed xml attributes come from xml->[title][description][link]->attributes->ITEM PROPERTY
RSS Feed xml interpretation points xml->channel->LISTOFITEMS(item)->ITEM PROPERTY
*/

// Generate an XML object to represent the data collected
$xml = simplexml_load_file($feedSelection->source) or die("Error: Could not connect to the feed");

// Get the last update time (for comparison with any articles to add)
$getLastPub = "SELECT `date_published` FROM `rss_feed` ORDER BY `data_id` DESC LIMIT 1";

// Get the one data point in a single line and convert to a DateTime object
// GET TIMEZONE on insert (The data entering the database will be of the same timezone as that leaving the database) --> pocket doesn't offer this offset so matching is the best way
$lastUpdateValue = $conn->query($getLastPub)->fetch_array()[0];

if ($lastUpdateValue != null) {
  $lastUpdate = new DateTime($lastUpdateValue, new DateTimeZone($timeZone));
} else {
  $lastUpdate = new DateTime('0000-00-00 00:00:00');
}
// Entry tracking class Definition
$summary = new Summary();

// Check each Entry from bottom to top (Added chronologically)
for ($entryNumber = count($xml->channel->item) - 1; $entryNumber >= 0; $entryNumber--) {
  // Set the $item tag as is done in a foreach loop (Pathing from RSS Feed)
  $item = $xml->channel->item[$entryNumber];
  // Convert the Date to a DateTime Object
  $dateAdded = new DateTime($item->pubDate);
  // Check if the entry is a new addition to the pocket
  if ($dateAdded > $lastUpdate) {
    // Insert the item into the database
    // Filter title for SQL injection
    $filteredTitle = addslashes($item->title);
    // Fetch Featured image URL
    $featuredImage = getImage($item->link);
    // Format Date Time for mySQL
    $dateAdded = $dateAdded->format('Y-m-d H:i:s');
    // MySQL Statement
    $addEntry = "INSERT INTO `rss_feed` (`title`,`link`,`feature_image`,`date_published`) VALUES ('$filteredTitle','$item->link','$featuredImage','$dateAdded')";
    if ($conn->query($addEntry)) { // Report all succcessful entries to the user
      $summary->entriesAdded++;
      array_push($summary->entriesList, $item->title);
    } else { // Keep a record of all failed additions
      $summary->entriesFailed++;
      array_push($summary->failuresList, $item->title);
      $summary->failureReason = $conn->error;
    }
  } else {
    break; // Stop when one is older than the last update as the feed data is chronological
  }
}

// Summary of Action
echo "<b>" . $summary->entriesAdded . " entries have been added to the database, including: </b></br>";
foreach ($summary->entriesList as $title) {
  echo $title . "</br>";
}
// Handle for failed actions report
if ($summary->entriesFailed > 0) {
  echo $summary->entriesFailed . " entries failed to be added to the database table due to: '" . $summary->failureReason . "'";
}

return $summary; // To be returned to administrative page on a forced update



// DEFINED functions

function getImage($url) {
  // Run a query to the page for source contents
  $pageContents = @file_get_contents($url);
  // If the url cannot be accessed, make another attempt as a user
  if ($pageContents == null || $pageContents == false) {
    // Mimic a user browser request to work around potential 401 FORBIDDEN errors
    $userAgent = 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36';
    // Instantiate and configure a cURL to mimic a user request (uses the cURL library)
    $curl = curl_init();
    curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, false);
    curl_setopt($curl, CURLOPT_VERBOSE, true);
    curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($curl, CURLOPT_USERAGENT, $userAgent);
    curl_setopt($curl, CURLOPT_URL, $url);
    // Run a query to the page for source contents using a viewer context
    $pageContents = curl_exec($curl);
    // If the page content is still null following this, the site is unreachable, null should be returned
    if ($pageContents == null || $pageContents == false) {
      return null;
    }
  } 
  // Check for schema.org inclusion (this is used to determine compatibility)
  if (strpos($pageContents, 'schema.org"') !== false) {
    // Remove whitespaces for uniformity of string searches
    $noWhiteContent = str_replace(' ','',$pageContents);
    // Select the beginning position of the required section
    $beginningPos = strpos($noWhiteContent, '"@context":"http://schema.org"');
    // Find the end and create a string that includes only required properties
    $contentsTrim = substr($noWhiteContent, $beginningPos, strpos($noWhiteContent,'</script>', $beginningPos) - $beginningPos);
    // Select each instance of ":{" --> if it is preceeded by "image", it contains the image url.
    $nextContainsURL = false; // Define the variable to prevent exceptions
    foreach (explode(":{",$noWhiteContent) as $segment) {
      if ($nextContainsURL) {
        $honedURL = substr($segment, strpos($segment, "url"),-1);
        $imageURL = explode('"',$honedURL)[2];
        return validated($imageURL);
      }
      if (substr($segment, strlen($segment) - 7, 7) == '"image"') { // Check if the last characters of a segment are the correct ones for an "image":{} property
        // Flag the next segment as that with the URL
        $nextContainsURL = true;
      }
    }
    return null;
  } elseif (strpos($pageContents,'<div class="post-body__content"><figure') !== false) {
    $contentsTrim = substr($pageContents, strpos($pageContents, '<div class="post-body__content"><figure'), 600);
    $targetURL = substr($contentsTrim, strpos($contentsTrim, '<img src='), 400);
    $imageURL = explode('"',$targetURL)[1];
    return validated($imageURL);
  } elseif (strpos($pageContents, "og:image") !== false) { // Cover Wikipedia articles which never use schema.org but are common
    $contentsTrim = substr($pageContents, strpos($pageContents, "og:image"), 600);
    $imageURL = explode('"',$contentsTrim)[2];
    return validated($imageURL);
  } else { // The page is not compatible with the method
    return null;
  }
}

function validated($imgURL) {
  // Make a library of supported extensions
  $supportedExtensions = ['bmp','jpg','jpeg','png','gif','webp'];
  // Breakdown the URL for the file extension (as the extension is of an unknown length)
  $breakdownForExtension = explode(".",$imgURL);
  $extension = $breakdownForExtension[count($breakdownForExtension) - 1];
  //Protect extension validation from addition image properties on the image URL
  $extension = explode("?",$extension)[0];
  // Validate the extension or return null for the URL if the extension is invalid
  $validURL = (in_array($extension, $supportedExtensions)) ? $imgURL : null;
  return $validURL;
}

?>
