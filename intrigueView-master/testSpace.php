<?php 

$url = "https://engadget.com/amp/2017/09/17/ai-alzheimers-early-detection";

$contents = getPageContents($url);

$link = getImage($contents);

echo validateImageLink($link);

function getPageContents($pageURL) {
  // Run a query to the page for source contents
  $pageContents = @file_get_contents($pageURL);
  // If the url cannot be accessed, make another attempt as a user
  if ($pageContents == null || $pageContents == false) {
    $pageContents = getContentsAsUser($pageURL);
    if ($pageContents == null) {
      return null;
    }
  } 
  return $pageContents;
}

function getContentsAsUser($pageURL) {
  // Mimic a user browser request to work around potential 401 FORBIDDEN errors
  $userAgent = 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36';
  // Instantiate and configure a cURL to mimic a user request (uses the cURL library)
  $curl = curl_init();
  curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, false);
  curl_setopt($curl, CURLOPT_VERBOSE, true);
  curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
  curl_setopt($curl, CURLOPT_USERAGENT, $userAgent);
  curl_setopt($curl, CURLOPT_URL, $pageURL);
  // Run a query to the page for source contents using a viewer context
  $pageContents = curl_exec($curl);
  // If the page content is still null following this, the site is unreachable, null should be returned
  if ($pageContents == null || $pageContents == false) {
    return null;
  }
  return $pageContents;
}

function getImage($pageContent) {
  // Check for schema.org inclusion (this is used to determine compatibility)
  if (strpos($pageContent, 'schema.org"') !== false) {
    // Remove whitespaces for uniformity of string searches
    $noWhiteContent = preg_replace('/\s*/m','',$pageContent);
    // Select the beginning position of the required section
    $beginningPos = strpos($noWhiteContent, '"@context":"http://schema.org"');
    $beginningPos = ($beginningPos == null) ? strpos($noWhiteContent, '"@context":"https://schema.org"') : $beginningPos;
    // Find the end and create a string that includes only required properties
    $contentsTrim = substr($noWhiteContent, $beginningPos, strpos($noWhiteContent,'</script>', $beginningPos) - $beginningPos);
    // Remove the [] in cases where developers decided to throw those in
    $noBracketing = str_replace('[','',$contentsTrim);
    $noBracketingFinal = str_replace(']','',$noBracketing);
    // Select each instance of ":{" --> if it is preceeded by "image", it contains the image url.
    $nextContainsURL = false; // Define the variable to prevent exceptions
    foreach (explode(":{",$noBracketingFinal) as $segment) {
      if ($nextContainsURL) {
        $honedURL = substr($segment, strpos($segment, "url"),-1);
        $imageURL = explode('"',$honedURL)[2];
        return $imageURL;
      }
      if (substr($segment, strlen($segment) - 7, 7) == '"image"') { // Check if the last characters of a segment are the correct ones for an "image":{} property
        // Flag the next segment as that with the URL
        $nextContainsURL = true;
      }
    }
    return null;
  } elseif (strpos($pageContent,'<div class="post-body__content"><figure') !== false) {
    $contentsTrim = substr($pageContent, strpos($pageContent, '<div class="post-body__content"><figure'), 600);
    $targetURL = substr($contentsTrim, strpos($contentsTrim, '<img src='), 400);
    $imageURL = explode('"',$targetURL)[1];
    return $imageURL;
  } elseif (strpos($pageContent, "og:image") !== false) { // Cover Wikipedia articles which never use schema.org but are common
    $contentsTrim = substr($pageContent, strpos($pageContent, "og:image"), 600);
    $imageURL = explode('"',$contentsTrim)[2];
    return $imageURL;
  } else { // The page is not compatible with the method
    return null;
  }
}

function validateImageLink($imgURL) {
  // Make a library of supported extensions
  $supportedExtensions = ['bmp','jpg','jpeg','png','gif','webp','ico'];
  // Interpret URL if it is from a URI scheme
  do {
    $imgURL = str_replace('%25','%',$imgURL); // Interpret percentage signs
    $urlPos = strpos($imgURL, "image_uri");
    $cdnLinkNoEnd = substr($imgURL, $urlPos);
    $cdnLink = explode('&',$cdnLinkNoEnd)[0];
    // Fix the equals signs where they've been reformatted
    $cdnLink = str_replace('%3D','=',$cdnLink);
    $cdnLink = preg_replace('~image_uri=~','',$cdnLink,1);
    // reformat the link as a URL, as URI practice converts slashes into codes
    // Fix the http colons
    $firstReplace = str_replace('%3A', ':', $cdnLink);
    // Fix the /'s
    $imgURL = str_replace('%2F', "/", $firstReplace);
    // Fix the &'s
    $imgURL = str_replace('%26', "&", $firstReplace);
  } while (false !== strpos($imgURL, "image_uri"));  // In some cases, 3 image_uri formattings are buried inside eachother
  // Interpret all /'s final 
  $imgURL = str_replace('%2F', '/', $imgURL);
  // Breakdown the URL for the file extension (as the extension is of an unknown length)
  $breakdownForExtension = explode(".",$imgURL);
  $extension = $breakdownForExtension[count($breakdownForExtension) - 1];
  //Protect extension validation from addition image properties on the image URL
  $extension = trim(explode("?",$extension)[0]);
  // Validate the extension or return null for the URL if the extension is invalid
  $validURL = (in_array($extension, $supportedExtensions)) ? $imgURL : null;
  return $validURL;
}
 ?>
