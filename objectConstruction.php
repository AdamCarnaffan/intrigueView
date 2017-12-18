<?php

class Entry {

  public $feedName;
  public $id;
  public $title;
  public $url;
  public $image;
  public $synopsis;
  public $siteURL;
  public $siteIcon;
  public $entryDisplaySize;
  public $contextMenu;
  public $tags = [];

  public function __construct($dataArray, $dataTags, $displayContext) {
    // Get all data from the Query. Indexes are based on position in the query
    // $this->feedName = $dataArray[0];
    $this->title = $dataArray[0];
    $this->url = $dataArray[1];
    $this->image = $dataArray[3];
    $this->synopsis = $dataArray[4];
    $this->isFeatured = ($dataArray[5] == 1) ? true : false; // Create a boolean based on the data table output. This boolean decides highlighting
    $this->siteURL = $dataArray[6];
    $this->siteIcon = $dataArray[7];
    $this->id = $dataArray[8];
    // Build the tags array
    while ($row = $dataTags->fetch_array()) {
      $this->tags[$row[2]] = $row[1];
    }
    if ($displayContext == "Saved") {
      $this->contextMenu = "X FOR REMOVING";
    } else {
      $this->contextMenu = "<a href='#' class='context-display' onclick='return saveEntry(this, " . $this->id . ")'><span class='fa fa-plus fa-context-style'></span></a>";
    }
  }

  public function displayEntryTile($entryDisplay, $featuredTiles) {
    if (in_array($entryDisplay, $featuredTiles)) { // Decide if the article will be a feature or not
      $this->entryDisplaySize = 2;
    } else {
      $this->entryDisplaySize = 1;
    }
    // Begin building the entry tile
    if ($this->entryDisplaySize == 1) {
      $tile = '<div class="col-6 col-lg-3 tile-wrapper">';
    } else {
      $tile = '<div class="col-12 col-lg-6 tile-wrapper">';
    }
    // Add entry tile Class
    $tile .= '<div class="entry-tile';
    if ($this->isFeatured) {
      $tile .= ' featured-tile';
    }
    $tile .= '">';
    // Add Article URL
    $tile .= '<a href="' . $this->url . '" onclick="return openInNewTab(\'' . $this->url . '\')" class="hover-detect"><span class="entry-url"></span></a>';
    // Add Article Heading
    $tile .= '<h5 class="entry-heading">' . $this->title . '</h5>';
    // Add Top Tags
    $tile .= '<div class="entry-stats tag-shift">Tags: ';
    // Initialize a counter
    $c = 1;
    foreach ($this->tags as $id=>$tag) {
      // Stop after the third tag on smaller entry tiles
      if ($this->entryDisplaySize == 1 && $c > 3) {
        break;
      }
      $tile .= '<a class="tag" href="#" onclick="return addTag(' . $id . ')">' . $tag . '</a> ';
      $c++;
    }
    $tile .= '</div>';
    // Add Article Feature Image if available
    if ($this->image != null) {
      $tile .= '<div class="image-container"><img class="image" src="' . $this->image . '"/></div>';
    } elseif ($this->synopsis != null) {
      // Add the synopsis here (STYLING INCOMPLETE)
      $synopsisExcerpt = trim(substr($this->synopsis, 0, 270));
      if (strlen($synopsisExcerpt) > 267) {
        $synopsisExcerpt .= "...";
      }
      $tile .= '<div class="synopsis-container centered"><p class="synopsis">' . $synopsisExcerpt . '</p></div>';
    } else {
      $tile .= '<div class="image-container"><img class="image fill-size" src="assets/tileFill.png"/></div>';
    }
    // Add Site Stats
    $tile .= '<div class="entry-stats">';
    // Site Icon
    if ($this->siteIcon != null) { // Handle cases where site icons haven't fetched properly or don't exist
      $tile .= '<img src="' . $this->siteIcon . '" class="site-icon"/>';
    }
    // Site URL (hyperlink)
    $linkedURL = "http://" . $this->siteURL;
    $tile .= '<a class="site-info-url" href="' . $linkedURL . '">';
    // Site URL (visual)
    $tile .= $this->siteURL . '</a>';
    // Context Display
    $tile .= $this->contextMenu;
    // Close all required tags
    $tile .= '</div></div></div>';
    return $tile;
  }

}

class FeedDisplay {

  public $name;
  public $id;
  public $size;
  public $updateRate;
  public $description;
  public $imagePath;
  public $author;
  public $categories = [];

  public function __construct($dataPackage, $dbConn) {
    $this->id = $dataPackage[0];
    $this->author = $dataPackage[1];
    $this->name = $dataPackage[2];
    $this->imagePath = $dataPackage[3];
    $this->description = $dataPackage[4];
    $this->size = $dataPackage[5];
    $this->getCategories($dbConn);
  }

  public function getCategories($dbConn) {
    $getCatsQuery = "SELECT categories.categoryID, categories.label FROM feed_categories AS catConn
                      JOIN categories ON categories.categoryID = catConn.categoryID
                      WHERE catConn.feedID = '$this->id'";
    $categoriesReturned = $dbConn->query($getCatsQuery);
    while ($catSelected = $categoriesReturned->fetch_array()) {
      $this->categories[$row[0]] = $row[1];
    }
    if (count($this->categories) < 1) {
      array_push($this->categories, "Unsorted");
    }
  }

  public function generateTile() {
    /* EXAMPLE
    <div class='feed-tile'>
      <div class='feed-tile-image-container'>
        <img class='feed-tile-image' src='https://beebom-redkapmedia.netdna-ssl.com/wp-content/uploads/2016/01/Reverse-Image-Search-Engines-Apps-And-Its-Uses-2016.jpg'>
      </div>
      <div class='feed-tile-info'>
        <a href="viewFeed.php?feedID=2" onclick='return selectFeed(2)' class='hover-detect'><span class='entry-url'></span></a>
        <h4 class='feed-tile-title'>This is the name of the feed</h4>
        <p class='feed-tile-desc'>This is the feed descrption, it's kinda long and whatever, but ya know....</p>
        <div class='feed-tile-footer'>
          <b>Categories: </b>
          <a class='tag' href='#' onclick='return false'>Cat1</a>
          <a class='tag' href='#' onclick='return false'>Cat2</a>
          <a class='tag' href='#' onclick='return false'>Cat3</a>
          <a class='context-display' href='#' onclick='return false'><span class='fa fa-plus fa-context-style'></span></a>
        </div>
      </div>
    </div>
    */
    $tile = "<div class='feed-tile'><div class='feed-tile-image-container'>";
    // Add the image
    if ($this->imagePath == null || $this->imagePath == "") {
      $this->imagePath = "assets/feedFiller.jpg";
    }
    $tile .= "<img class='feed-tile-image' src='" . $this->imagePath . "'></div>";
    // Begin feed info divider
    $tile .= "<div class='feed-tile-info'>";
    // Feed Reference
    $tile .= "<a href='viewFeed.php?feedID=" . $this->id . "' onclick='return selectFeed(this, " . $this->id . ")' class='hover-detect'><span class='entry-url'></span></a>";
    // Feed Title
    $tile .= "<h4 class='feed-tile-title'>" . $this->name . "</h4>";
    // Feed Description
    $tile .= "<p class='feed-tile-desc'>" . $this->description . "</p>";
    // Begin feed footer divider
    $tile .= "<div class='feed-tile-footer'>";
    // Generate Categories
    $tile .= "<b>Categories: </b>";
    foreach ($this->categories as $catID=>$category) {
      $tile .= "<a class='tag' href='#' onclick='return sortByCategory(" . $catID . ")'>" . $category . "</a>";
    }
    // Place the Subscription button
    $tile .= "<a class='context-display' href='#' onclick='return saveFeed(this, " . $this->id . ")'><span class='fa fa-plus fa-context-style'></span></a>";
    // Close all divs
    $tile .= "</div></div></div>";
    return $tile;
  }

}

class PotentialTag {
  public $tag;
  public $frequency;

  public function __construct($index, $value) {
    $this->tag = $index;
    $this->frequency = $value;
  }

}

Class Tag extends PotentialTag {

  public $weight;
  public $priority;

  public function __construct($potentialTagObject, $weighting) {
    $this->tag = $potentialTagObject->tag;
    $this->frequency = $potentialTagObject->frequency;
    $this->weight = $weighting;
  }

  public function prioritize() {
    $this->priority = round($this->frequency*$this->weight);
  }
}

class SiteData {

  public $siteIcon;
  public $siteURL;
  public $siteID;
  public $feedID;
  public $imageURL;
  public $synopsis;
  public $pageContent;
  public $articleContent;
  public $title;
  public $tags;

  public function __construct($url, $feedID, $dbConn, $tagBlackList) {
    $this->feedID = $feedID; // PLACEHOLDER FOR FEED DATA SUBMISSION
    // Get the contents of the site page
    $this->pageContent = $this->getPageContents($url);
    if ($this->pageContent == null) {
      // Try without https
      $url = str_replace('https://', 'http://', $url);
      $this->pageContent = $this->getPageContents($url);
      if ($this->pageContent == null) {
        throw new Exception("The URL is invalid or the page does not accept outside requests");
        return;
      }
    }
    $this->articleContent = $this->getArticleContents();
    // get the Site URL for a cross check with the database
    $this->siteURL = explode("/",$url)[2];
    // Remove the www subdomain if it occurs
    $this->siteURL = str_replace("www.", "", $this->siteURL);
    // Check for the site URL in the database sites table
    $getSiteInfo = "SELECT siteID, icon FROM sites WHERE url = '$this->siteURL'";
    if ($tempInfo = $dbConn->query($getSiteInfo)) { // Check that the query is successful
      $siteResult = $tempInfo->fetch_array();
      if (count($siteResult) > 0) { // Check for the return of a result
        $this->siteIcon = null; // If the site is already in the database, the site icon does not matter
        $this->siteID = $siteResult['siteID'];
      } else {
        // Get the site icon from the contents
        $this->siteIcon = $this->validateImageLink($this->getSiteIconURL($this->pageContent));
        // Submit the site to the database as a new site entry
        $insertSite = "INSERT INTO sites (url, icon) VALUES ('$this->siteURL','$this->siteIcon')";
        if ($dbConn->query($insertSite)) {
          $this->siteID = $dbConn->insert_id;
        } else {
          throw new Exception($dbConn->error);
        }
      }
    } else {
      throw new Exception($dbConn->error);
    }
    // Get the title from the page
    $this->title = $this->getTitle($this->pageContent);
    // Find the feature image on the page
    $this->imageURL = $this->validateImageLink($this->getImage($this->pageContent));
    // Get an excerpt of text from the article to display if no feature image is found
    $this->synopsis = trim(addslashes($this->getExcerpt($this->pageContent)));
    // Build tags
    $tagBuilder = function (&$tagArray, $frequency) use ($tagBlackList) {
      foreach ($tagArray as $tagKey=>&$tag) {
        // Convert the tag to the proper output formatting (string appearance)
        // Check if the second letter of a string is uppercase (indicates acronym)
        if (strlen($tag) > 1) {
          $secondChar = str_split($tag)[1];
          if (!in_array($secondChar, range('A','Z'))) {
            $tag = strtolower($tag);
          }
        }
        $tag = str_replace('-', ' ', $tag);
        $letters = str_split($tag);
        // Capitalize the first letter of each word
        foreach ($letters as $key=>&$letter) {
          $val = $key - 1;
          if ($val < 0 || $letters[$val] == null || $letters[$val] == " ") {
            $letter = strtoupper($letter);
          }
        }
        // Put the word back together
        $tag = implode($letters);
        // Remove tags that appear in the tag blacklist
        if (in_array($tag, $tagBlackList)) {
          unset($tagArray[$tagKey]);
        }
      }
      // Convert all remaining tags into PotentialTag objects
      foreach ($tagArray as &$tag) {
        $tag = new PotentialTag($tag, $frequency);
      }
      // Order and index submission array
      if (count($tagArray) > 1 && $frequency == 1) {
        $tagArray = array_values($tagArray);
      }
    };
    // Call functions to build tag arrays
    $authorTags = $this->getAuthorTags($this->pageContent); // Try to ommit author name from these tags on return
    $titleKeywords = $this->getTags($this->title);
    $contentTags = $this->getTags($this->articleContent);
    $urlTags = $this->getURLTags($url);
    $siteMainURL = explode('.',$this->siteURL)[0]; // Get ONLY the main URL
    //$soughtTags = seekTags($articleContent);
    // Convert all tags
    $articleTags = [];
    foreach ($contentTags as $tag=>$frequency) {
      // Make a fake array to use in an array based reference function
      $fakeArray = [$tag];
      $tagBuilder($fakeArray, $frequency);
      // Push each individual tag to the array after computation
      if (count($fakeArray) > 0) {
        array_push($articleTags, $fakeArray[0]);
      }
    }

    // Convert URL tags to the weighted tag format
    if (count($urlTags) > 0) {
      $tagBuilder($urlTags, 1);
    }

    // Convert Author tags to the weighted tag format
    if (count($authorTags) > 0) {
      $tagBuilder($authorTags, 1);
    }

    // Convert title tags to the weighted tag format
    $titleTags = [];
    foreach ($titleKeywords as $tag=>$frequency) {
      // Make a fake array to use in an array based reference function
      $fakeArray = [$tag];
      $tagBuilder($fakeArray, $frequency);
      // Push each individual tag to the array after computation
      if (count($fakeArray) > 0) {
        array_push($titleTags, $fakeArray[0]);
      }
    }
    // Weight the tags based on factors

    // Author Tags --> INPUT 1
    // Content Tags --> INPUT 2
    // Title Tags --> INPUT 3
    // URL Tags --> INPUT 4
    $weightedTags = $this->checkCommonality($authorTags, $articleTags, $titleTags, $urlTags, $siteMainURL);
    // Determine final order
    $this->tags = $this->computeWeighting($weightedTags);
  }

  public function getArticleContents() {
    $articleContent = ['defaultClassing' => '']; // Initialize default as the value when no classes are present
    $pTagSeparated = explode("<p", $this->pageContent);
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
    return $this->stripHTMLTags($finalContent);
  }

  public function stripPunctuation($string) {
    $punctuation = ['?', ".", "!", ",", "-", '"', "&quot;", "]", "[", "(", ")", "'s", "&#x27;s"];
    // Replace dashes with spaces to separate words
    $wordConnectors = ['—', '-'];
    $string = str_replace($wordConnectors, " ", $string);
    return str_replace($punctuation, "", $string);
  }

  public function stripHTMLTags($contents) {
    // Find and remove any script from the excerpt (scripting happens inbetween tags and isn't caught by the other method)
    $contentNoScript = preg_replace("/<script\b[^>]*>(.*?)<\/script>/is", " ", $contents);
    // Remove Styling info
    $contentNoStyling = preg_replace("/<style\b[^>]*>(.*?)<\/style>/is", " ", $contentNoScript);
    // Remove html tags and formatting from the excerpt
    $contentNoHTML = preg_replace("#\<[^\>]+\>#", " ", $contentNoStyling);
    // Clean additional whitespaces
    return preg_replace("#\s+#", " ", $contentNoHTML);
  }

  // TAG FUNCTIONS

  public function getURLTags($inputURL) {
    $noDashes = explode("-", $inputURL); // All URLs with content pertanent to the article separate these words with dashes
    $indexCountFirstWord = count(explode('/', $noDashes[0]));
    $noDashes[0] = explode('/', $noDashes[0])[$indexCountFirstWord - 1]; // Break the first word from remaining URL
    $lastIndex = count($noDashes)-1;
    $noDashes[$lastIndex] = explode('/', $noDashes[$lastIndex])[0]; // Break the last word from any remaining URL
    $noDashes[$lastIndex] = explode('.', $noDashes[$lastIndex])[0]; // Remove the File Type should the words be the end of the URL
    return $noDashes;
  }

  public function eliminateBadTags($string) {
    if (strpos($string, '/') !== false || strpos($string, '@') !== false || strpos($string, '%') !== false || strpos($string, ';') !== false || strpos($string, ':') !== false || strpos($string, '#') !== false || strpos($string, '&') !== false) {
      return false;
    }
    if (!preg_match('~[A-Za-z]~', $string)) {
      return false;
    }
    return true;
  }

  public function getTags($content) {
    $tags = [];
    $fillerWords = ['when', 'said', 'dr', 'after', 'my', 'doesn’t', 'who', 'now', 'most', 'place', 'should', 'best', 'create', 'some', 'see', 'var', 'amp', 'click', "i'd", 'per', 'mr', 'ms', 'mrs', 'dr', 'called', 'go', 'also', 'each', 'seen', 'where', 'going', 'were', 'would', 'will', 'your', 'so', 'where', 'says', 'off', 'into', 'how', 'you', 'one', 'two', 'three', 'four', 'know', 'say', 'five', 'six', 'seven', 'eight', 'nine', 'ten', 'way', 'get', 'been', 'his', 'her', 'are', 'was', 'few', 'finally', 'not', 'can', 'be', 'exactly', 'our', 'still', 'need', 'up', 'down', 'new', 'old', 'the', 'own', 'enough', 'which', 'is', 'at', 'did', "don't", 'even', 'out', 'like', 'make', 'them', 'and', 'no', 'yes', 'on', 'why', "hasn't", 'hasn&#x27;t', 'then', 'we’re', 'we’re', 'or', 'do', 'any', 'if', 'that’s', 'could', 'only', 'again', "it’s", 'use', 'i', "i'm", 'i’m', 'it', 'as', 'in', 'from', 'an', 'yet', 'but', 'while', 'had', 'its', 'have', 'about', 'more', 'than', 'then', 'has', 'a', 'we', 'us', 'he', 'they', 'their', "they're", 'they&#x27;re', 'they&#x27;d', "they'd", 'this', 'he', 'she', 'to', 'for', 'without', 'all', 'of', 'with', 'that', "that's", 'what', 'by', 'just', "we're"];
    $splitContent = explode(' ', $this->stripPunctuation($content));
    foreach ($splitContent as &$word) {
      // Remove ALL whitespace
      $word = str_replace("&nbsp;", "", $word);
      $word = preg_replace('~\s+~', "", $word);
      // Check for intersection with blacklist
      if (in_array(strtolower($word), $fillerWords)) {
        $word = "";
      }
      // Remove quotation marks at the end of the words
      $word = str_replace('&#x27;', '', $word);
    }
    $tagList = [];
    foreach ($splitContent as $tag) {
      // Any Tag must be longer than 1 character, non-numeric and not contain any descriptive punctuation
      if (strlen($tag) > 1 && !is_numeric($tag) && $this->eliminateBadTags($tag)) {
        if (isset($tagList[$tag])) {
          $tagList[$tag]++;
        } else {
          $tagList[$tag] = 1;
        }
      }
    }
    arsort($tagList);
    // Set Minimum count based on total number of tags IF there are more than 50 tags
    if (count($tagList) > 30) {
      $required = count($tagList) / 10;
      $required = ($required > 2) ? 2 : $required;
    } else {
      $required = 0;
    }
    // Filter out tags that don't appear frequently enough
    foreach ($tagList as $tag=>$frequency) {
      if ($frequency > $required) {
        $tags[$tag] = $frequency;
      } elseif (count($tags) < 30) { // Continue to add tags until there are 50, then stop accepting tags
        $tags[$tag] = $frequency;
      }
    }
    return $tags;
  }

  public function getAuthorTags($pageContent) {
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

  // Tag Evaluations
  public function checkCommonality($input1, $input2, $input3, $input4, $siteURL) {
    $author = [];
    $content = [];
    $title = [];
    $url = [];
    $siteURL = strtolower($siteURL);
    // Put author tags into array, forgetting weighting
    foreach ($input1 as $tagObject) {
      array_push($author, $tagObject->tag);
    }
    // Put Content tags into array, forgetting weighting
    foreach ($input2 as $tagObject) {
      array_push($content, $tagObject->tag);
    }
    // Put Title tags into array, forgetting weighting
    foreach ($input3 as $tagObject) {
      array_push($title, $tagObject->tag);
    }
    // Put URL tags into array, forgetting weighting
    foreach ($input4 as $tagObject) {
      array_push($url, $tagObject->tag);
    }
    /*
    PRIORITY LIST
    -----------------
    1) Intersections with URL
    2) Intersections with Author Tags
    3) Intersections with Title

    RULES
    -----------------
    -> All Author Tags are kept, though weighted lowly without intersections
    -> Title Tags are ONLY kept if they intersect with another kind of tag
    -> URL Tags are only used for this step, and are then discarded
    -> Content Tags are kept should they intersect OR appear in a Frequency above 5
    -> When writing intersections, CONTENT tags always go first to keep the index
    */
    // URL INTERSECTION
    // Check URL-Author intersection
    $outURLAuth = array_intersect($author, $url);
    // Get things that are in the main site URL
    foreach($author as $tag) {
      if (strpos(strtolower($tag), $siteURL) !== false) {
        array_push($outURLAuth, $tag);
      }
    }
    // Remove any added duplicate values
    $outURLAuth = array_unique($outURLAuth);
    // Check URL-Content intersection
    $outURLCont = array_intersect($content, $url);
    // Get things that are in the main site URL
    foreach($content as $tag) {
      if (strpos(strtolower($tag), $siteURL) !== false) {
        array_push($outURLCont, $tag);
      }
    }
    // Remove any added duplicate values
    $outURLCont = array_unique($outURLCont);
    // Check URL-Title Intersection
    $outURLTitle = array_intersect($title, $url);
    // AUTHOR INTERSECTION
    $outAuthCont = array_intersect($content, $author);
    $outAuthTitle = array_intersect($title, $author);
    // TITLE INTERSECTION
    $outTitleCont = array_intersect($content, $title);
    // OUTPUT INTERSECTIONS
    $outURLContAuth = array_intersect($outURLCont, $outURLAuth);
    $outURLContTitle = array_intersect($outURLCont, $outTitleCont);
    $outURLTotal = array_unique($outURLContAuth + $outURLContTitle);
    $outURLTotal = array_unique($outURLTotal);
    $outAuthTotal = array_intersect($outAuthCont, $outAuthTitle);
    // Output Weighting
    /*
    TRIPLE W/ URL --> 5
    TRIPLE W/O URL --> 2
    DOUBLE W/ URL --> 2
    DOUBLE W/ Auth --> 1.3
    DOUBLE W/ Title --> 0.8
    CONTENT FREQ TOP 10% --> 0.4
    */
    // Weighting Variables
    $tripleU = 5;
    $subjects = 3;
    $triple = 2;
    $doubleU = 1.8;
    $doubleA = 1.3;
    $doubleT = 0.8;
    $contFreq = 0.4;
    // Process All Final Tags
    $tagOutput = [];
    // TRIPLE W/ URL
    foreach ($outURLTotal as $contentIndex=>$name) {
      array_push($tagOutput, new Tag($input2[$contentIndex], $tripleU));
    }
    // Title & URL --> Article Subjects
    foreach ($outURLTitle as $name) {
      $exists = false;
      // Check that the tag is not already added
      foreach ($tagOutput as $tagOut) {
        if ($tagOut->tag == $name) {
          $exists = true;
          break;
        }
      }
      if (!$exists) {
        $tempPotent = new PotentialTag($name, 1);
        array_push($tagOutput, new Tag($tempPotent, $subjects));
      }
    }
    // TRIPLE W/O URL
    foreach ($outAuthTotal as $contentIndex=>$name) {
      $exists = false;
      // Check that the tag is not already added
      foreach ($tagOutput as $tagOut) {
        if ($tagOut->tag == $name) {
          $exists = true;
          break;
        }
      }
      if (!$exists) {
        array_push($tagOutput, new Tag($input2[$contentIndex], $triple));
      }
    }
    // DOUBLE W/ URL
    foreach (array_unique($outURLAuth + $outURLCont) as $contentIndex=>$name) {
      $exists = false;
      // Check that the tag is not already added
      foreach ($tagOutput as $tagOut) {
        if ($tagOut->tag == $name) {
          $exists = true;
          break;
        }
      }
      if (!$exists) {
        array_push($tagOutput, new Tag($input2[$contentIndex], $doubleU));
      }
    }
    // DOUBLE W/ Author
    foreach (array_unique($outAuthCont + $outAuthTitle) as $contentIndex=>$name) {
      $exists = false;
      // Check that the tag is not already added
      foreach ($tagOutput as $tagOut) {
        if ($tagOut->tag == $name) {
          $exists = true;
          break;
        }
      }
      if (!$exists) {
        array_push($tagOutput, new Tag($input2[$contentIndex], $doubleA));
      }
    }
    // DOUBLE W/ Author
    foreach ($outTitleCont as $contentIndex=>$name) {
      $exists = false;
      // Check that the tag is not already added
      foreach ($tagOutput as $tagOut) {
        if ($tagOut->tag == $name) {
          $exists = true;
          break;
        }
      }
      if (!$exists) {
        array_push($tagOutput, new Tag($input2[$contentIndex], $doubleT));
      }
    }
    // TOP 10% of Content Tags
    if (count($input2) > 1) {
      for ($c = 0; $c <= count($input2)*0.1; $c++) {
        $exists = false;
        // Check that the tag is not already added
        foreach ($tagOutput as $tagOut) {
          if ($tagOut->tag == $input2[$c]->tag) {
            $exists = true;
            break;
          }
        }
        if (!$exists) {
          array_push($tagOutput, new Tag($input2[$c], $contFreq));
        }
      }
    }
    return $tagOutput;
  }

  public function computeWeighting($tags) {
    $prioritizedTags = [];
    foreach ($tags as &$tag) {
      $tag->prioritize();
      if (!isset($prioritizedTags[$tag->priority])) {
        $prioritizedTags[$tag->priority] = $tag->tag;
      } else {
        for ($priorityCheck = $tag->priority - 1; $priorityCheck >= 0; $priorityCheck--) {
          if (!isset($prioritizedTags[$priorityCheck])) {
            $prioritizedTags[$priorityCheck] = $tag->tag;
            break;
          }
        }
      }
    }
    // Add a placeholder value
    array_push($prioritizedTags, 'PLACEHOLDER');
    // Sort the now prioritized tags by index descending, then re-index
    krsort($prioritizedTags);
    $prioritizedTags = array_values($prioritizedTags);
    // Remove the placeholder value, now the array begins at index 1 for DB submission
    unset($prioritizedTags[0]);
    return $prioritizedTags;
  }

  // -----------------------------------------------------------

  public function getImage($pageContent) {
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
    } elseif (strpos($pageContent, '"og:image"') !== false) { // Cover Wikipedia type articles which never use schema.org but are common
      $contentByMeta = explode("<meta", $pageContent);
      foreach ($contentByMeta as $content) {
        if (strpos($content, '"og:image"')) {
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

  public function getPageContents($pageURL) {
    // Run a query to the page for source contents
    $pageContents = @file_get_contents($pageURL);
    // If the url cannot be accessed, make another attempt as a user
    if ($pageContents == null || $pageContents == false) {
      $pageContents = $this->getContentsAsUser($pageURL);
      if ($pageContents == null) {
        return null;
      }
    }
    return $pageContents;
  }

  public function validateImageLink($imgURL) {
    // Make a library of supported extensions
    $supportedExtensions = ['bmp','jpg','jpeg','png','gif','webp','ico'];
    // Interpret URL if it is from a URI scheme
    do {
      $imgURL = str_replace('%25','%',$imgURL); // Interpret percentage signs
      if (false !== strpos($imgURL, "image_uri")) {
        // The Distribution takes place through a routed network, the true URL is embedded
        $urlPos = strpos($imgURL, "image_uri");
        $cdnLinkNoEnd = substr($imgURL, $urlPos);
        $cdnLink = explode('&',$cdnLinkNoEnd)[0];
        $embedded = true;
      } else {
        // The Distribution is not through a routed CDN
        $cdnLink = $imgURL;
        $embedded = false;
      }
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
    if ($embedded) {
      // Interpret all /'s final
      $imgURL = str_replace('%2F', '/', $imgURL);
      return $imgURL;
    }
    // Breakdown the URL for the file extension (as the extension is of an unknown length)
    $breakdownForExtension = explode(".",$imgURL);
    $extension = $breakdownForExtension[count($breakdownForExtension) - 1];
    //Protect extension validation from addition image properties on the image URL
    $extension = trim(explode("?",$extension)[0]);
    // Validate the extension or return null for the URL if the extension is invalid
    $validURL = (in_array($extension, $supportedExtensions)) ? $imgURL : null;
    return $validURL;
  }

  private function getContentsAsUser($pageURL) {
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

  public function getSiteIconURL($pageContents) {
    // Arriving here indicated that the URL was not found in the <link> tags
    if (strpos($pageContents, 'schema.org"') !== false && strpos($pageContents, '"logo":') !== false || strpos($pageContents, '"logo" :') !== false) {
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
          $honedURL = substr($segment, strpos($segment, "url"),-1);
          // If the image is subdivided into another object, progress to that segment instead
          if (isset(explode('"',$honedURL)[2])) {
            $imageURL = explode('"',$honedURL)[2];
            return $imageURL;
          }
        }
        if (substr($segment, strlen($segment) - 6, 6) == '"logo"') { // Check if the last characters of a segment are the correct ones for an "image":{} property
          // Flag the next segment as that with the URL
          $nextContainsURL = true;
        }
      }
    }
    $linkTagSelection = explode("<link",$pageContents);
    // Remove content from before the <link> tag
    array_shift($linkTagSelection);
    // Remove the content after the close of the last />
    if (count($linkTagSelection) > 0) {
      $lastTagIndex = count($linkTagSelection)-1;
      $linkTagSelection[$lastTagIndex] = explode(">", $linkTagSelection[$lastTagIndex])[0];
    }
    foreach ($linkTagSelection as $tag) {
      if (strpos($tag, '"icon"') !== false || strpos($tag, " icon") !== false || strpos($tag, "icon ") !== false) {
        $iconURL = explode('href="', $tag)[1];
        $iconURL = explode('"', $iconURL)[0];
        $iconURLFinal = $this->checkURLPathing($iconURL);
        return $iconURLFinal;
      } elseif (strpos($tag, "'icon'") !== false) { // Use the single quotation mark in the case where it is used in the rel
        $iconURL = explode("href='", $tag)[1];
        $iconURL = explode("'", $iconURL)[0];
        $iconURLFinal = $this->checkURLPathing($iconURL);
        return $iconURLFinal;
      }
    }
    return null;
  }

  public function getExcerpt($pageContents) {
    // The excerpt is always assumed the first paragraph of an article
    $attempt = 0;
    start:
    $selectedParagraph = explode("</p>",$pageContents)[$attempt]; // Paragraph ends at the ending tag
    // Paragraph begins at the beginning tag prior to the ending tag. Processed based on p having or not having tags
    if (isset(explode("<p ", $selectedParagraph)[1])) {
      $cutStart = explode("<p ", $selectedParagraph)[1];
      $excerptTagged = substr($cutStart, strpos($cutStart, ">") + 1); // The paragraph is all that is inbetween the paragraph tags
    } else {
      if (isset(explode("<p>", $selectedParagraph)[1])) {
        $excerptTagged = explode("<p>", $selectedParagraph)[1];
      } else {
        return null;
      }
    }
    // Find and remove any script from the excerpt (scripting happens inbetween tags and isn't caught by the other method)
    $excerptNoScript = preg_replace("#(<script.*?>).*?(</script>)#", " ", $excerptTagged);
    // Remove html tags and formatting from the excerpt
    $excerptNoHTML = preg_replace("#\<[^\>]+\>#", " ", $excerptNoScript);
    // Clean additional whitespaces
    $excerptClean = preg_replace("#\s+#", " ", $excerptNoHTML);
    // Check that the excerpt contains content
    if (!array_intersect(str_split($excerptClean), range('a','z')) || strlen($excerptClean) < 80) {
      if ($attempt > 10) { // Timeout for attempting to get excerpt
        return null;
      }
      $attempt++;
      goto start; // This is bad, I know
    }
    return $excerptClean;
  }

  public function clearData() {
    $this->imageURL = null;
    $this->synopsis = " ";
    $this->pageContent = null;
  }

  public function checkURLPathing($url) {
    if (substr(strtolower($url), 0, 4) != 'http') {
      $urlNew = "http://" . $this->siteURL . $url;
      return $urlNew;
    } else {
      return $url;
    }
  }

  public function getTitle($pageContents) {
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
}

class User {

  public $id;
  public $name;
  public $permissions = [];
  public $feed;
  public $subscriptions;

  public function __construct($userData, $dbConn) {
    $this->id = $userData['id'];
    $this->name = $userData['username'];
    $this->feed = $userData['feedID']; // The user's personal Feed ID
    $this->getPerms($dbConn);
    $this->getSubs($dbConn);
  }

  public function getPerms($conn) {
    $this->permissions = []; // Reset the permissions array for refresh
    $getPerms = "SELECT permissionID, feedID FROM user_permissions WHERE userID = '$this->id'";
    if ($result = $conn->query($getPerms)) {
      while ($row = $result->fetch_array()) {
        $tempPerm = new Permission($row[0],$row[1]);
        array_push($this->permissions, $tempPerm);
      }
    }
  }

  public function getSubs($conn) {
    $this->subscriptions = []; // Reset the subscriptions available in myFeed
    $getComps = "SELECT internalFeedID FROM user_subscriptions WHERE userID = '$this->id'";
    if ($result = $conn->query($getComps)) {
      while ($row = $result->fetch_array()) {
        // Push all subscriptions to an array
        array_push($this->subscriptions, $row[0]);
      }
      // Remove the user's Feed from subscriptions
      $userFeedIndex = array_search($this->feed, $this->subscriptions);
      unset($this->subscriptions[$userFeedIndex]);
      $this->subscriptions = array_values($this->subscriptions);
    }
  }

}

class Permission {

  public $permissionId;
  public $feedId; // 0/null indicates all feeds

  public function __construct($permId, $feedId) {
    $this->permissionId = $permId;
    $this->feedId = $feedId;
  }

}

class Summary {

  public $entriesAdded = 0;
  public $entriesList = [];
  public $entriesFailed;
  public $failuresList = [];
  public $failureReason;

  public function __construct() {}

}

class FeedInfo {

  public $title;
  public $source;
  public $id;
  public $busy;
  public $isExternal = false;

  public function __construct($feedId, $dbConn, $isExternal) {
    $this->id = $feedId;
    if ($isExternal) {
      $feedType = "external_feeds";
      $includedFields = "url, title, busy";
      $idColumn = "externalFeedID";
      $this->isExternal = true;
    } else {
      $feedType = "user_feeds";
      $includedFields = "title";
      $idColumn = "internalFeedID";
    }
    $sourceQuery = "SELECT $includedFields FROM $feedType WHERE $idColumn = '$this->id' AND active = 1";
    if ($result = $dbConn->query($sourceQuery)) {
      $sourceInfo = $result->fetch_array();
    } else {
      throw new exception($dbConn->error);
    }
    $this->source = (isset($sourceInfo['url'])) ? $sourceInfo['url'] : null;
    $this->title = $sourceInfo['title'];
    $this->busy = (isset($sourceInfo['busy'])) ? $sourceInfo['busy'] : 0;
  }

}



 ?>
