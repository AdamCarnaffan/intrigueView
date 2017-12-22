<?php

$url = "http://www.freetech4teachers.com/2017/12/5-good-alternatives-to-google-image.html?cachebusterTimestamp=1513951824233#.Wj0SVt-nGUk";
$content = getPageContents($url);
echo getImage($content);

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
  if (strpos($pageContent, 'schema.org"') !== false && strpos($pageContent, '"image":') !== false || strpos($pageContent, '"image" :') !== false) {
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
        // If the image is subdivided into another object, progress to that segment instead
        if (isset(explode('"',$honedURL)[2])) {
          $imageURL = explode('"',$honedURL)[2];
          return $imageURL;
        }
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
  } elseif (strpos($pageContent, '"og:image"') !== false || strpos($pageContent, "'og:image'") !== false) { // Cover Wikipedia type articles which never use schema.org but are common
    $contentByMeta = explode("<meta", $pageContent);
    foreach ($contentByMeta as $content) {
      if (strpos($content, '"og:image"') || strpos($content, "'og:image'")) {
        $contentTrim = explode("/>", $content)[0];
        $contentTag = substr($contentTrim, strpos($contentTrim, "content="));
        // Cover cases where single quotes are used to define content (outliers)
        if (isset(explode('"', $contentTag)[1])) {
          $imageURL = explode('"', $contentTag)[1];
        } else {
          $imageURL = explode("'", $contentTag)[1];
        }
        break;
      }
    }
    return $imageURL;
  } else { // The page is not compatible with the method
    return null;
  }
}

function stripPunctuation($string) {
  $punctuation = ['?', ".", "!", ",", "-", '"', "&quot;", "]", "[", "(", ")", "'s", "&#x27;s"];
  // Replace dashes with spaces to separate words
  $wordConnectors = ['—', '-'];
  $string = str_replace($wordConnectors, " ", $string);
  return str_replace($punctuation, "", $string);
}

function stripHTMLTags($contents) {
  // Find and remove any script from the excerpt (scripting happens inbetween tags and isn't caught by the other method)
  $contentNoScript = stripScripting($contents);
  // Remove Styling info
  $contentNoStyling = preg_replace("/<style\b[^>]*>(.*?)<\/style>/is", " ", $contentNoScript);
  // Remove html tags and formatting from the excerpt
  $contentNoHTML = preg_replace("#\<[^\>]+\>#", " ", $contentNoStyling);
  // Clean additional whitespaces
  return preg_replace("#\s+#", " ", $contentNoHTML);
}

function stripScripting($contents) {
  return preg_replace("/<script\b[^>]*>(.*?)<\/script>/is", " ", $contents);
}

?>
