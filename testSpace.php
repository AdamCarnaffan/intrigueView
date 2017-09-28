<?php 

$url = "http://www.freetech4teachers.com/2017/08/diy-augmented-reality-3-ways-to-use-it.html";

$contents = getPageContents($url);

$first = getTitle($contents);

echo $first;

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

function getTitle($pageContent) {
  if (strpos($pageContent, "og:title") !== false) {
    // Break down the content by meta tags to look for the title tag
    $contentByMeta = explode("<meta", $pageContent);
    foreach ($contentByMeta as $content) {
      if (strpos($content, "og:title")) {
        // Separate the title meta tag from the rest of the content
        $contentTrim = explode("/>", $content)[0];
        // trim for only the content property
        $contentTag = substr($contentTrim, strpos($contentTrim, "content="));
        // Get the title
        // To cover outlier cases where single quotes are used in lieu
        if (isset(explode('"', $contentTag)[1])) {
          $finalTitle = addslashes(explode('"', $contentTag)[1]);
        } else {
          $finalTitle = addslashes(explode("'", $contentTag)[1]);
        }
        break;
      }
    }
  } else {
    $titleSection = explode("<title>", $pageContent)[1];
    $endTitle = explode("</title>", $titleSection)[0];
    $finalTitle = addslashes($endTitle);
  }
  return $finalTitle;
}

 ?>
