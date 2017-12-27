<?php 
require_once('lib/vendor/autoload.php');
require_once('objectConstruction.php');

// Modifiable Variables
$googleServiceAccPath = "F:/UniformServer/UniServerZ/Google_API/service.json";

// Generate a client
$client = new Google_Client();
putenv('GOOGLE_APPLICATION_CREDENTIALS=' . $googleServiceAccPath);
$client->useApplicationDefaultCredentials();
$client->setScopes(['https://www.googleapis.com/auth/books']);
$engineID = '017024561452473323470:vibdg2pnw_e';

// Create a search 
$search = new Google_Service_Customsearch($client);


/*

Idea: The feature takes tag data submitted and uses the data to find related articles online through google news

1) Fetch Global / Personal data (input)
  -Get data and weight factors from database for incoming query
  

2) Apply Data to Google News Query (output)
  -Take top recent results for the Query
  -Check that the site of the result is not on the site blacklist (fake news filter)
  -Process the entry through the usual entry processing method
  -Submit the entry object for validation

3) Check for match between fetched article and original data (validation)



Grab all entries simultaneously into a temporary table
process the entries all together
insert the relevant ones and discard those that don't apply
Generate 5 user recommendations for each user on the hour every hour
Generate 10 feed recommendations every day for each feed (external and non-personal only)
Display the user's recommended entries in their personal feed, and in a recommendations browser page

*/




 ?>
