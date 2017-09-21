<?php 

$url = "https://engadget.com/amp/2017/09/18/northrop-grumman-acquires-orbital-atk";

public function getImage($pageContent) {
  // Check for schema.org inclusion (this is used to determine compatibility)
  if (strpos($pageContent, 'schema.org"') !== false) {
    // Remove whitespaces for uniformity of string searches
    $noWhiteContent = str_replace(' ','',$pageContent);
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
 ?>
