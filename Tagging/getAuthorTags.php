<?php

class PotentialTag {
  public $tag;
  public $frequency;
  
  public function __construct($index, $value) {
    $this->tag = $index;
    $this->frequency = $value;
  }
  
}

function convertToTag(&$tagArray) {
  standardizeTags($tagArray, $tagBlackList);
  foreach ($tagArray as &$tag) {
    $tag = new PotentialTag($tag, 1);
  }
}

function standardizeTags(&$arrayOfTags, $blacklist) {
  foreach ($arrayOfTags as $key=>&$tag) {
    $tag = strtolower($tag);
    $tag = str_replace('-', ' ', $tag);
    $letters = str_split($tag);
    foreach ($letters as $key=>&$letter) {
      $val = $key - 1;
      if ($val < 0 || $letters[$val] == null || $letters[$val] == " ") {
        $letter = strtoupper($letter);
      }
    }
    $tag = implode($letters);
    if (in_array($tag, $blacklist)) {
      unset($arrayOfTags[$key]);
    }
  }
}

///////////////////////////////////////////////     / \
///      TAGS NEED TO BE VALIDATED WITH     ///    / | \
///          WITH THE TAG BLACKLIST!        ///      |
///////////////////////////////////////////////      |


// Prompt a tag to be blacklisted when deleted from an entry
$tagBlackList = ['Top Image', 'Related Video', 'Know', 'Say', 'Default']; // This will be cached from the DB on a new fetch

$url = "https://www.wired.com/story/us-kaspersky-ban-evidence/";

$content = getContentsAsUser($url);

$title = getTitle($content);
$articleContent = getArticleContents($content);

// Get All Tags as arrays
$authorTags = getAuthorTags($content);
$titleTags = getTags($title);
$contentTags = getTags($articleContent);
$soughtTags = seekTags($articleContent);

// Convert Content tags into weighted article tags
$articleTags = [];
foreach ($contentTags as $tag=>$frequency) {
  // Make a fake array to use in an array based reference function
  $fakeArray = [$tag];
  standardizeTags($fakeArray, $tagBlackList);
  // Pass parameters into a new array, creating tags with weighting
  array_push($articleTags, new PotentialTag($fakeArray[0], $frequency));
}

// Convert Author tags to the weighted tag format
if (count($authorTags) > 0) {
  convertToTag($authorTags);
}

// Convert title tags to the weighted tag format
convertToTag($titleTags);


$totalTags = ['author'=>$authorTags, 'title'=>$titleTags, 'content'=>$articleTags];

//print_r($totalTags);
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

function seekTags($articleContent) {
  return [];
}

// Function to create tags based on frequency of word inclusion, then ommit connecting words
function getTags($articleContent) {
  $tags = [];
  $fillerWords = ['the', 'own', 'enough', 'which', 'is', 'at', 'did', "don't", 'even', 'out', 'like', 'make', 'them', 'and', 'no', 'yes', 'on', 'why', "hasn't", 'hasn&#x27;t', 'then', 'we’re', 'we’re', 'or', 'do', 'any', 'if', 'that’s', 'could', 'only', 'again', "it’s", 'use', 'i', "i'm", 'i’m', 'it', 'as', 'in', 'from', 'an', 'yet', 'but', 'while', 'had', 'its', 'have', 'about', 'more', 'than', 'then', 'has', 'a', 'we', 'us', 'he', 'they', 'their', "they're", 'they&#x27;re', 'they&#x27;d', "they'd", 'this', 'he', 'she', 'to', 'for', 'without', 'all', 'of', 'with', 'that', "that's", 'what', 'by', 'just', "we're"];
  $splitContent = explode(' ', strtolower(stripPunctuation($articleContent)));
  foreach ($splitContent as &$word) {
    if (in_array($word, $fillerWords)) {
      $word = "";
    }
    // Remove quotation marks at the end of the words
    $word = str_replace('&#x27;', '', $word);
  }
  foreach ($splitContent as $tag) {
    // Any Tag must be longer than 1 character
    if (strlen($tag) > 1) {
      if (isset($tagList[$tag])) {
        $tagList[$tag]++;
      } else {
        $tagList[$tag] = 1;
      }
    }
  }
  arsort($tagList);
  foreach ($tagList as $tag=>$frequency) {
    if ($frequency > 2) {
      $tags[$tag] = $frequency;
    }
  }
  return $tags;
}

// Function to fetch predefined tags from the meta data
function getAuthorTags($pageContent) {
  $tags = [];
  if (strpos($pageContent, 'schema.org"') !== false && strpos($pageContent, '"keywords":') !== false || strpos($pageContent, '"keywords" :') !== false) {
    // Take out white space for uniformity
    $noWhiteSpace = preg_replace('/\s*/m', '', $pageContent);
    // Get the begining position of the schema
    $startPos = strpos($noWhiteSpace, '"@context":"http://schema.org"');
    $startPos = ($startPos == null) ? strpos($noWhiteSpace, '"@context":"https://schema.org"') : $startPos;
    // Get the Schema information script
    $finalContent = substr($noWhiteSpace, $startPos, strpos($noWhiteSpace, '</script>', $startPos) - $startPos);
    // Select the Keywords tag from the schema
    $keyWordSelect = explode('"keywords":', $pageContent)[1];
    // Breakdown the element into a list of components
    $tagList = explode('[', $keyWordSelect)[1];
    $tagListFinished = explode(']', $tagList)[0];
    $removeTagQuotes = str_replace('"', "", $tagListFinished);
    // Explode the list into individual elements of an array
    $initialTagArray = explode(',', $removeTagQuotes);
    foreach ($initialTagArray as $tag) {
      array_push($tags, trim($tag));
    }
  }
  return $tags;
}

function stripPunctuation($string) {
  $punctuation = ['?', ".", "!", ",", "-", '"', "&quot;", "]", "[", "(", ")", "'s", "&#x27;s"];
  // Replace dashes with spaces to separate words
  $wordConnectors = ['—', '-'];
  $string = str_replace($wordConnectors, " ", $string);
  return str_replace($punctuation, "", $string);
}


?>
