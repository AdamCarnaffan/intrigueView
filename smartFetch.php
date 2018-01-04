<?php
require_once('lib/vendor/autoload.php');
require_once('objectConstruction.php');

$searchTerms = "AI"; // The value from the database for the query cycle

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

// https://developers.google.com/apis-explorer/?cachebusterTimestamp=1514304833602&hl=en_US#p/customsearch/v1/search.cse.list?q=AI&cx=017024561452473323470%253Avibdg2pnw_e&dateRestrict=d2&googlehost=google.ca&_h=1&
// https://github.com/google/google-api-php-client
// Build php class to construct this parameter tree programatically

/*

array(
                'methods' => array(
                  'list' => array(
                    'path' => 'v1',
                    'httpMethod' => 'GET',
                    'parameters' => array(
                      'q' => array(
                        'location' => 'query',
                        'type' => 'string',
                        'required' => true,
                      ),
                      'c2coff' => array(
                        'location' => 'query',
                        'type' => 'string',
                      ),
                      'cr' => array(
                        'location' => 'query',
                        'type' => 'string',
                      ),
                      'cx' => array(
                        'location' => 'query',
                        'type' => 'string',
                      ),
                      'dateRestrict' => array(
                        'location' => 'query',
                        'type' => 'string',
                      ),
                      'exactTerms' => array(
                        'location' => 'query',
                        'type' => 'string',
                      ),
                      'excludeTerms' => array(
                        'location' => 'query',
                        'type' => 'string',
                      ),
                      'fileType' => array(
                        'location' => 'query',
                        'type' => 'string',
                      ),
                      'filter' => array(
                        'location' => 'query',
                        'type' => 'string',
                      ),
                      'gl' => array(
                        'location' => 'query',
                        'type' => 'string',
                      ),
                      'googlehost' => array(
                        'location' => 'query',
                        'type' => 'string',
                      ),
                      'highRange' => array(
                        'location' => 'query',
                        'type' => 'string',
                      ),
                      'hl' => array(
                        'location' => 'query',
                        'type' => 'string',
                      ),
                      'hq' => array(
                        'location' => 'query',
                        'type' => 'string',
                      ),
                      'imgColorType' => array(
                        'location' => 'query',
                        'type' => 'string',
                      ),
                      'imgDominantColor' => array(
                        'location' => 'query',
                        'type' => 'string',
                      ),
                      'imgSize' => array(
                        'location' => 'query',
                        'type' => 'string',
                      ),
                      'imgType' => array(
                        'location' => 'query',
                        'type' => 'string',
                      ),
                      'linkSite' => array(
                        'location' => 'query',
                        'type' => 'string',
                      ),
                      'lowRange' => array(
                        'location' => 'query',
                        'type' => 'string',
                      ),
                      'lr' => array(
                        'location' => 'query',
                        'type' => 'string',
                      ),
                      'num' => array(
                        'location' => 'query',
                        'type' => 'integer',
                      ),
                      'orTerms' => array(
                        'location' => 'query',
                        'type' => 'string',
                      ),
                      'relatedSite' => array(
                        'location' => 'query',
                        'type' => 'string',
                      ),
                      'rights' => array(
                        'location' => 'query',
                        'type' => 'string',
                      ),
                      'safe' => array(
                        'location' => 'query',
                        'type' => 'string',
                      ),
                      'searchType' => array(
                        'location' => 'query',
                        'type' => 'string',
                      ),
                      'siteSearch' => array(
                        'location' => 'query',
                        'type' => 'string',
                      ),
                      'siteSearchFilter' => array(
                        'location' => 'query',
                        'type' => 'string',
                      ),
                      'sort' => array(
                        'location' => 'query',
                        'type' => 'string',
                      ),
                      'start' => array(
                        'location' => 'query',
                        'type' => 'integer',
                      ),
                    ),
                  ),
                )
              );
              
*/


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

foreach ($queryResults as $url) {
  
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
