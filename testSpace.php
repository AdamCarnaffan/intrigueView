<?php 

$url = "https://lifehacker.com/search-for-your-email-address-to-see-if-your-password-h-1819780168";

$pageContent = getPageContents($url);

echo getTitle($pageContent);

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

function getTitle($pageContents) {
  // Begin by checking meta tags for the title
  $linkTagSelection = explode("<meta",$pageContents);
  // Remove content from before the <link> tag
  array_shift($linkTagSelection);
  // Remove the content after the close of the last />
  if (count($linkTagSelection) > 0) {
    $lastTagIndex = count($linkTagSelection)-1;
    $linkTagSelection[$lastTagIndex] = explode("/>", $linkTagSelection[$lastTagIndex])[0];
  }
  foreach ($linkTagSelection as $tag) {
    if (strpos($tag, '"og:title"') !== false) {
      $titleStart = explode('content="', $tag)[1];
      if (!isset(explode('content="', $tag)[1])) {
        //echo $tag . "</br>" . $this->pageContent;
      }
      $titleFull = explode('"', $titleStart)[0];
      return $titleFull;
    } elseif (strpos($tag, "'og:title'") !== false) { // Use the single quotation mark in the case where it is used in the rel
      $titleStart = explode("content='", $tag)[1];
      $titleFull = explode("'", $titleStart)[0];
      return $titleFull;
    }
  }
  // Check here if a meta title is not available
  if (strpos($pageContents, "<title>") !== false) {
    $titleStart = explode("<title>", $pageContents)[1];
    $titleFull = explode("</title>", $titleStart)[0];
    return $titleFull;
  }
  // Arriving here indicated that the Title was not found in the <meta> tags OR <title> tags
  if (strpos($pageContents, 'schema.org"') !== false && strpos($pageContents, '"headline":') !== false || strpos($pageContents, '"headline" :') !== false) {
    // Remove whitespaces for uniformity of string searches
    $noWhiteContent = preg_replace('/\s*/m','',$pageContents);
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
        $honedURL = substr($segment, strpos($segment, "headline"),-1);
        // If the image is subdivided into another object, progress to that segment instead
        if (isset(explode('"',$honedURL)[2])) {
          $imageURL = explode('"',$honedURL)[2];
          return $imageURL;
        }
      }
      if (substr($segment, strlen($segment) - 10, 10) == '"headline"') { // Check if the last characters of a segment are the correct ones for an "image":{} property
        // Flag the next segment as that with the URL
        $nextContainsURL = true;
      }
    }
  }
  return null;
}


?>
