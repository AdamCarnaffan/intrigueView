<?php

$url = "https://dzone.com/articles/ai-and-machine-learning-trends-for-2018-what-to-ex";
$content = getPageContents($url);
$excerpt = getArticleContents($content, true);
echo $excerpt;
//echo $excerpt;

function getArticleContents($input, $needReadable = false) {
  $articleContent = ['defaultClassing' => '']; // Initialize default as the value when no classes are present
  $input = stripScripting($input);
  $pTagSeparated = explode("<p", $input);
  foreach ($pTagSeparated as $tag) {
    $validationChar = substr($tag, 0, 1); // Get the first following character from the HTML tag
    if ($validationChar == ">" || $validationChar == " ") { // To validate that we're looking at a <p> tag
      // The text within the <p></p> tags
      $textWithClass = explode("</p>", $tag)[0];
      // Operation to remove <p> attributes
      $textAlone = explode('>', $textWithClass);
      array_shift($textAlone); // To remove the text before the <p> closing tag
      $textAlone = implode($textAlone, ">");
      // The attributes of the <p> tag
      $textAttr = explode(">", $textWithClass)[0];
      // Sort into blank and filled Classes
      if (strpos(strtolower($textAttr), "class=") !== false) {
        $classes = substr($textAttr, strpos(strtolower($textAttr),"class="));
        // Accept classes denoted by either single or double quoation marks
        if (isset(explode("'", $classes)[1])) {
          $classes = explode("'", $classes)[1];
        } else {
          $classes = explode('"', $classes)[1];
        }
        if (isset($articleContent[$classes])) {
          $articleContent[$classes] .= $textAlone . " ";
        } else {
          $articleContent[$classes] = $textAlone . " ";
        }
      } else {
        if ($needReadable) {
          $articleContent['defaultClassing'] = (strlen($textAlone) > strlen($articleContent['defaultClassing'])) ? $textAlone : $articleContent['defaultClassing'];
        } else {
          $articleContent['defaultClassing'] .= $textAlone . " ";
        }
      }
    }
  }
  if (!function_exists('lengthSort')) {
    // Define a custom sort function that determines the difference in string length
    function lengthSort($stringA, $stringB) {
      return strlen($stringB) - strlen($stringA);
    }
  }
  // Sort the array in terms of content length (referenced from below)
  usort($articleContent, 'lengthSort');
  $finalContent = $articleContent[0];
  // Strip article of all other tags
  return stripHTMLTags($finalContent);
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

?>
