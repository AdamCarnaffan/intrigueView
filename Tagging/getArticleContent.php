<?php

$url = "https://design.tutsplus.com/tutorials/how-to-create-dripping-paint-photoshop-effect-action--cms-29620";

$content = getContentsAsUser($url);

$articleContent = getArticleContents($content);

$title = getTitle($content);

echo $articleContent;

// -----------------------------------------------


function stripHTMLTags($contents) {
  // Find and remove any script from the excerpt (scripting happens inbetween tags and isn't caught by the other method)
  $contentNoScript = preg_replace("#(<script.*?>).*?(</script>)#", " ", $contents);
  // Remove html tags and formatting from the excerpt
  $contentNoHTML = preg_replace("#\<[^\>]+\>#", " ", $contentNoScript);
  // Clean additional whitespaces
  return preg_replace("#\s+#", " ", $contentNoHTML);
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

function getArticleContents($pageContent) {
  $articleContent = ['defaultClassing' => '']; // Initialize default as the value when no classes are present
  $pTagSeparated = explode("<p", $pageContent);
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
        $articleContent['defaultClassing'] .= $textAlone . " ";
      }
    }
  }
  // Define a custom sort function that determines the difference in string length
  function lengthSort($stringA, $stringB) {
    return strlen($stringB) - strlen($stringA);
  }
  // Sort the array in terms of content length
  usort($articleContent, 'lengthSort');
  $finalContent = $articleContent[0];
  // Strip article of all other tags
  return stripHTMLTags($finalContent);
}


?>
