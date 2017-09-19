<?php

// Site Data Object to return (include site icon url, image url, synopsis)

class SiteData {
  
  public $siteIcon;
  public $imageURL;
  public $synopsis;
  
  public function __construct($url) {
    
    
  }
  
}


$pageURL = 'https://wired.com/story/gm-cruise-generation-3-self-driving-car/amp';
echo htmlspecialchars(getImage($pageURL)); // AS String
//echo "<img src='" . getImage($pageURL) . "' />"; // AS Image


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
