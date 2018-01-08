<?php
require_once('lib/vendor/autoload.php');
require_once('class/class_dataFetch.php');
require_once('dbConnect.php');

$searchTerms = "AI"; // The value from the database for the query cycle
$smartFetchFeedID = 36; // Value from database for smartFetch feed


// Modifiable Variables
$googleServiceAccPath = "F:/UniformServer/UniServerZ/Google_API/service.json";

// Generate a client
$client = new Google_Client();
putenv('GOOGLE_APPLICATION_CREDENTIALS=' . $googleServiceAccPath);
$client->useApplicationDefaultCredentials();
$client->setScopes(['https://www.googleapis.com/auth/cse']);
$engineID = '017024561452473323470:vibdg2pnw_e';

// Create a search
$search = new Google_Service_Customsearch($client);

// cx => Sets the Custom Search Engine Key (Used to search News sites only)
// dateRestrict => Only content from the last 2 days is worth querying
// googlehost => We'd like to use a local search, no albanian results thx <3

$params = array(
              'cx' => '017024561452473323470:vibdg2pnw_e',
              'dateRestrict' => 'd2',
              'googlehost' => 'google.ca'
            );

$results = $search->cse->listCse($searchTerms, $params);

$queryResults = [];

foreach ($results->getItems() as $item) {
  array_push($queryResults, $item->link);
}

// Fetch the tag blacklist in preperation
$getBlackList = "SELECT blacklistedTag FROM tag_blacklist";
$result = $conn->query($getBlackList);
$tagBlackList = []; // Initialize the array
while ($row = $result->fetch_array()) {
  // add each tag to the array
  array_push($tagBlackList, $row[0]);
}

$now = new DateTime("now");
$now = $now->format('Y-m-d H:i:s');

foreach ($queryResults as $url) {
  $tempEntry = new Entry_Data($url, $conn, $tagBlackList);
  $tempEntry->submitEntry($conn, $smartFetchFeedID, $now);
}


/*

Idea: The feature takes tag data submitted and uses the data to find related articles online through google news

1) Fetch Global Data (input)
  -Get data and weight factors from database for incoming query


2) Apply Data to Google News Query (output)
  -Process the entry through the usual entry processing method
  -Submit the entry object for validation

3) Check for match between fetched article and original data (validation)

The same query only returns 50% new results after 25 hours

Create a seperate serve function to serve recommendations to the user
*/




 ?>
