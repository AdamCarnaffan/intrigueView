<?php

require_once(ROOT_PATH . '/class/class_std.php');

class Tag_Potential extends Tag {

  public $frequency = 1;
  private static $blacklist;

  public function makeWeighted() {
    $weighted = new Tag_Weighted($this->name, $this->databaseID);
    $weighted->frequency = $this->frequency; // Conserve previous frequency
    return $weighted;
  } 
  
  public static function setBlackList($dbConn) {
    self::$blacklist = [];
    // Fetch the tag blacklist
    $getBlackList = "SELECT tags.tag FROM tag_blacklist AS tb JOIN tags ON tb.tag_id = tags.tag_id";
    $result = $dbConn->query($getBlackList);
    while ($row = $result->fetch_array()) {
      // add each tag to the array
      self::$blacklist[] = $row[0];
    }
    return;
  }
  
  public static function getBlackList() {
    return self::$blacklist;
  }
}

class Tag_Weighted extends Tag_Potential {

  public $weight;
  public $priority;

  public function prioritize() {
    $this->priority = round($this->frequency*$this->weight);
  }

}

class Entry_Data extends Entry {

  // Data exclusive
  public $pageContent;
  public $articleText;
  public $schema;
  public $meta;

  public function __construct($url, $dbConn) {
    $this->url = $url;
    // Get the contents of the site page
    $this->pageContent = getPageContents($url);
    if ($this->pageContent == null) {
      // Try without https
      $url = str_replace('https://', 'http://', $url);
      $this->pageContent = getPageContents($url);
      if ($this->pageContent == null) {
        throw new Exception("The URL is invalid or the page does not accept outside requests");
        return;
      }
    }
    $this->articleText = $this->getArticleContents();
    $this->schema = extractSchema($this->pageContent);
    $this->meta = Meta::extractMeta($this->pageContent);
    // get the Site URL for a cross check with the database
    $siteURL = explode("/",$url)[2];
    // Remove the www subdomain if it occurs
    $siteURL = str_replace("www.", "", $siteURL);
    // Check for the site URL in the database sites table
    $this->source = new Source_Site($siteURL);
    // Fetch any data from the site if needed
    if ($this->source->icon == null || $this->source->icon == "") {
      $this->source->getData($dbConn, $this);
    }
    // Get the title from the page
    $this->getTitle();
    // Find the feature image on the page
    $this->getImage();
    // Get an excerpt of text from the article to display if no feature image is found
    $this->synopsis = $this->getArticleContents(true);
    //echo $this->synopsis . "</br>";
    // Trim the synopsis (for legal purposes)
    //$this->synopsis = substr($this->synopsis, 0, 400);
    // Add a filler if the Synopsis doesn't exist
    if (strlen($this->synopsis) < 20) {
      $this->synopsis = "Click the article to see what it's about!";
    }
    
    // Call functions to build tag arrays
    $authorTags = $this->getAuthorTags($this->pageContent); // Try to ommit author name from these tags on return
    $titleTags = $this->getTags($this->title);
    $contentTags = $this->getTags($this->articleText);
    $urlTags = $this->getURLTags($url);
    $siteMainURL = explode('.',$this->source->url)[0]; // Get ONLY the main URL
    // $soughtTags = seekTags($articleContent);
    // Weight the tags based on factors

    // Author Tags --> INPUT 1
    // Content Tags --> INPUT 2
    // Title Tags --> INPUT 3
    // URL Tags --> INPUT 4
    $weightedTags = $this->checkCommonality($authorTags, $contentTags, $titleTags, $urlTags, $siteMainURL);
    // Determine final order
    $this->tags = $this->computeWeighting($weightedTags);
    // Check for Plural tags
    foreach ($this->tags as &$tagFinal) {
      // Convert all tags to generic tag objects
      $tagObject = new Tag($tagFinal);
      // Begin comparing tags for singulars
      // if (!$tagObject->consolidate($dbConn)) {
      //   if ($tagObject->checkPluralization()) {
      //     // Check article for singulars
      //     foreach ($tagObject->generateTagSingulars() as $single) {
      //       if (stripos($this->pageContent, " {$single} ") !== false) {
      //         $tagObject->name = $single;
      //       }
      //     }
      //   }
      // }
      // Turn each tag into a Tag object
      $tagFinal = $tagObject;
    }
  }

  public function submitEntry(mysqli $dbConn, $feedID, $date) {
    // Escape strings
    $this->title = $dbConn->real_escape_string($this->title);
    $this->synopsis = $dbConn->real_escape_string($this->synopsis);
    // Build the Query
    $addEntry = "CALL newEntry('{$this->source->id}','$feedID', '$this->title','$this->url','$date','$this->image','$this->synopsis', @newID);
                  SELECT @newID;";
    $sortOrder = 1;
    foreach ($this->tags as $tag) {
      $addEntry = $addEntry . "CALL addTag('$tag->name', @newID, '$sortOrder'); ";
      $sortOrder++;
    }
    if ($dbConn->multi_query($addEntry)) {
      // Cycle to second query
      $dbConn->next_result();
      // Get the new entry's ID
      $this->id = $dbConn->store_result()->fetch_array()[0];
      // Add the tags with connections
      return true;
    } else { // The inital multi-query failed
      throw new exception($dbConn->error);
    }
  }

  public function getArticleContents($needReadable = false) { // FIX THIS FUNCTION
    if ($needReadable) {
      // Check for schema.org inclusion (this is used to determine compatibility)
      if ($this->schema != null) {
        if (property_exists($this->schema, "description")) {
          return $this->schema->description;
        }
      }
      // Check Meta inclusion
      if ($this->meta != null) {
        foreach ($this->meta as $dat) {
          if ($dat->name == "og:description") {
            return $dat->value;
          }
        }
      }
    }
    $articleContent = ['defaultClassing' => '']; // Initialize default as the value when no classes are present
    $input = stripScripting($this->pageContent);
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
          //echo $classes . "</br>";
          if (isset(explode("'", $classes)[1])) {
            $classes = explode("'", $classes)[1];
          } else {
            $classes = explode('"', fixHTMLChars($classes))[1];
          }
          if (isset($articleContent[$classes])) {
            $articleContent[$classes] .= $textAlone . " ";
          } else {
            $articleContent[$classes] = $textAlone . " ";
          }
        } else {
          if ($needReadable) {
            $articleContent['defaultClassing'] = (strlen(stripHTMLTags($textAlone)) > strlen(stripHTMLTags($articleContent['defaultClassing']))) ? $textAlone : $articleContent['defaultClassing']; // Change the content out if the new content adds significant value
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

  // TAGGING RELATED FUNCTIONS

  public function buildTags(array $tagArray) {
    // tagArray format is [tagName]=>[frequency]
    $tagObjectList = [];
    #region Clean String
    // Build tags
    foreach ($tagArray as $tag=>$frequency) {
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
      // Add to cleaned array
      $tempTag = new Tag_Potential($tag);
      if (in_array($tempTag->name, $tempTag->getBlackList())) continue;
      $tempTag->frequency = $frequency;
      $tagObjectList[] = $tempTag;
    }
    #endregion
    return $tagObjectList;
  }

  public function getURLTags($inputURL) {
    $noDashes = explode("-", $inputURL); // All URLs with content pertanent to the article separate these words with dashes
    $indexCountFirstWord = count(explode('/', $noDashes[0]));
    $noDashes[0] = explode('/', $noDashes[0])[$indexCountFirstWord - 1]; // Break the first word from remaining URL
    $lastIndex = count($noDashes)-1;
    $noDashes[$lastIndex] = explode('/', $noDashes[$lastIndex])[0]; // Break the last word from any remaining URL
    $noDashes[$lastIndex] = explode('.', $noDashes[$lastIndex])[0]; // Remove the File Type should the words be the end of the URL
    $finalArray = [];
    foreach ($noDashes as $tagName) {
      $finalArray[$tagName] = 1;
    }
    return $this->buildTags($finalArray);
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
    $fillerWords = ['when', 'there', 'loading', 'said', 'dr', 'after', 'my', 'doesn’t', 'who', 'now', 'most', 'good', 'receiving', 'place', 'should', 'best', 'using', 'create', 'some', 'see', 'var', 'amp', 'click', "i'd", 'per', 'mr', 'ms', 'mrs', 'dr', 'called', 'go', 'also', 'each', 'seen', 'where', 'going', 'were', 'would', 'will', 'your', 'so', 'where', 'says', 'off', 'into', 'how', 'you', 'one', 'two', 'three', 'four', 'know', 'say', 'five', 'six', 'seven', 'eight', 'nine', 'ten', 'way', 'get', 'been', 'his', 'her', 'are', 'was', 'few', 'finally', 'not', 'can', 'be', 'exactly', 'our', 'still', 'need', 'up', 'down', 'new', 'old', 'the', 'own', 'enough', 'which', 'is', 'at', 'did', "don't", 'even', 'out', 'like', 'make', 'them', 'and', 'no', 'yes', 'on', 'why', "hasn't", 'hasn&#x27;t', 'then', 'we’re', 'we’re', 'or', 'do', 'any', 'if', 'that’s', 'could', 'only', 'again', "it’s", 'use', 'i', "i'm", 'i’m', 'it', 'as', 'in', 'from', 'an', 'yet', 'but', 'while', 'had', 'its', 'have', 'about', 'more', 'than', 'then', 'has', 'a', 'we', 'us', 'he', 'they', 'their', "they're", 'they&#x27;re', 'they&#x27;d', "they'd", 'this', 'he', 'she', 'to', 'for', 'without', 'all', 'of', 'with', 'that', "that's", 'what', 'by', 'just', "we're"];
    $splitContent = explode(' ', stripPunctuation($content));
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
    return $this->buildTags($tags);
  }

  public function getAuthorTags($pageContent) {
    $tags = [];
    if ($this->schema != null) {
      if (property_exists($this->schema, "keywords")) {
        if (is_array($this->schema->keywords)) {
          foreach ($this->schema->keywords as $word) {
            $tags[] = $word;
          }
        } else {
          $tags[] = $this->schema->keywords;
        }
      }
    }
    // Check Meta inclusion
    if ($this->meta != null) {
      foreach ($this->meta as $dat) {
        if ($dat->name == "parsely-tags") {
          foreach (explode(",", $dat->value) as $word) {
            $tags[] = $word;
          }
        }
      }
    }
    $tags = array_unique($tags);
    // Filter tags for useless default tags
    $defs = ["default", "top-image", "related-video"];
    $finals = [];
    foreach ($tags as $tg) {
      if (in_array($tg, $defs)) {
        continue;
      }
      $finals[] = $tg;
    }
    return $this->buildTags($finals);
  }

  // Tag Evaluations
  public function checkCommonality($input1, $input2, $input3, $input4, $siteURL) {
    $author = [];
    $content = [];
    $title = [];
    $url = [];
    $siteURL = strtolower($siteURL);
    // Put author tags into array, forgetting frequency
    foreach ($input1 as $tagObject) {
      array_push($author, $tagObject->name);
    }
    // Put Content tags into array, forgetting frequency
    foreach ($input2 as $tagObject) {
      array_push($content, $tagObject->name);
    }
    // Put Title tags into array, forgetting frequency
    foreach ($input3 as $tagObject) {
      array_push($title, $tagObject->name);
    }
    // Put URL tags into array, forgetting frequency
    foreach ($input4 as $tagObject) {
      array_push($url, $tagObject->name);
    }
    // print_r([$input1, $input2, $input3, $input4]);
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
    foreach($content as $contIndex=>$tag) {
      if (strpos(strtolower($tag), $siteURL) !== false) {
        $outURLCont[$contIndex] = $tag;
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
    DOUBLE W/ URL --> 1.8
    DOUBLE W/ Auth --> 3
    DOUBLE W/ Title --> 0.8
    CONTENT FREQ TOP 10% --> 0.4
    */
    // Weighting Variables
    $tripleU = 5;
    $subjects = 3;
    $triple = 2;
    $doubleU = 1.8;
    $doubleA = 3;
    $doubleT = 0.8;
    $contFreq = 0.4;
    // Process All Final Tags
    $tagOutput = [];
    // TRIPLE W/ URL
    foreach ($outURLTotal as $contentIndex=>$name) {
      $tempTag = $input2[$contentIndex]->makeWeighted();
      $tempTag->weight = $tripleU;
      array_push($tagOutput, $tempTag); // weighted
    }
    // Title & URL --> Article Subjects
    foreach ($outURLTitle as $name) {
      $exists = false;
      // Check that the tag is not already added
      foreach ($tagOutput as $tagOut) {
        if ($tagOut->name == $name) {
          $exists = true;
          break;
        }
      }
      if (!$exists) {
        $tempTag = new Tag_Weighted($name);
        $tempTag->weight = $subjects;
        array_push($tagOutput, $tempTag);
      }
    }
    // TRIPLE W/O URL
    foreach ($outAuthTotal as $contentIndex=>$name) {
      $exists = false;
      // Check that the tag is not already added
      foreach ($tagOutput as $tagOut) {
        if ($tagOut->name == $name) {
          $exists = true;
          break;
        }
      }
      if (!$exists) {
        $tempTag = $input2[$contentIndex]->makeWeighted();
        $tempTag->weight = $triple;
        array_push($tagOutput, $tempTag); // weighted
      }
    }
    // DOUBLE W/ URL
    foreach (array_unique($outURLAuth + $outURLCont) as $contentIndex=>$name) {
      $exists = false;
      // Check that the tag is not already added
      foreach ($tagOutput as $tagOut) {
        if ($tagOut->name == $name) {
          $exists = true;
          break;
        }
      }
      if (!$exists) {
        $tempTag = $input2[$contentIndex]->makeWeighted();
        $tempTag->weight = $doubleU;
        array_push($tagOutput, $tempTag); // weighted
      }
    }
    // DOUBLE W/ Author
    foreach (array_unique($outAuthCont + $outAuthTitle) as $contentIndex=>$name) {
      $exists = false;
      // Check that the tag is not already added
      foreach ($tagOutput as $tagOut) {
        if ($tagOut->name == $name) {
          $exists = true;
          break;
        }
      }
      if (!$exists) {
        $tempTag = $input2[$contentIndex]->makeWeighted();
        $tempTag->weight = $doubleA;
        array_push($tagOutput, $tempTag); // weighted
      }
    }
    // DOUBLE W/ Author
    foreach ($outTitleCont as $contentIndex=>$name) {
      $exists = false;
      // Check that the tag is not already added
      foreach ($tagOutput as $tagOut) {
        if ($tagOut->name == $name) {
          $exists = true;
          break;
        }
      }
      if (!$exists) {
        $tempTag = $input2[$contentIndex]->makeWeighted();
        $tempTag->weight = $doubleT;
        array_push($tagOutput, $tempTag); // weighted
      }
    }
    // TOP 10% of Content Tags
    if (count($input2) > 1) {
      for ($c = 0; $c <= count($input2)*0.1; $c++) {
        $exists = false;
        // Check that the tag is not already added
        foreach ($tagOutput as $tagOut) {
          if ($tagOut->name == $input2[$c]->name) {
            $exists = true;
            break;
          }
        }
        if (!$exists) {
          $tempTag = $input2[$c]->makeWeighted();
          $tempTag->weight = $contFreq;
          array_push($tagOutput, $tempTag);
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
        $prioritizedTags[$tag->priority] = $tag->name;
      } else {
        for ($priorityCheck = $tag->priority - 1; $priorityCheck >= 0; $priorityCheck--) {
          if (!isset($prioritizedTags[$priorityCheck])) {
            $prioritizedTags[$priorityCheck] = $tag->name;
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

  public function getImage() {
    // Check for schema.org inclusion (this is used to determine compatibility)
    if ($this->schema != null) {
      if (property_exists($this->schema, "image")) {
        if (is_array($this->schema->image)) {
          $this->image = validateImageLink($this->schema->image[0]->url);
        } else {
          $this->image = validateImageLink($this->schema->image->url);
        }
        return;
      }
    }
    // Check Meta inclusion
    if ($this->meta != null) {
      foreach ($this->meta as $dat) {
        if ($dat->name == "og:image") {
          $this->image = validateImageLink($dat->value);
          return;
        }
      }
    }
    if (strpos($this->pageContent,'<div class="post-body__content"><figure') !== false) {
      $contentsTrim = substr($this->pageContent, strpos($this->pageContent, '<div class="post-body__content"><figure'), 600);
      // echo $contentsTrim;
      $targetURL = substr($contentsTrim, strpos($contentsTrim, '<img src='), 400);
      $imageURL = explode('"',$targetURL)[1];
      $this->image = validateImageLink($imageURL);
      return;
    }
    // The page is not compatible with the method
    return;
  }

  public function getTitle() {
    // Check Meta for Title
    if ($this->meta != null) {
      foreach ($this->meta as $dat) {
        if ($dat->name == "og:title") {
          $this->title = $dat->value;
          return;
        }
      }
    }
    // Check here if a meta title is not available
    if (strpos($this->pageContent, "<title>") !== false) {
      $titleStart = explode("<title>", $this->pageContent)[1];
      $titleFull = explode("</title>", $titleStart)[0];
      $this->title = $titleFull;
      return;
    }
    // Check for schema.org inclusion
    if ($this->schema != null) {
      if (property_exists($this->schema, "headline")) {
        $this->title = $this->schema->headline;
        return;
      }
    }
    return;
  }
  
  public static function doesExist($url, $feedID, $dbConn) {
    $getDuplicateEntry = "SELECT IF(COUNT(*) > 0, TRUE, FALSE) as res FROM entries WHERE url = '$url'";
    if ($dbConn->query($getDuplicateEntry)->fetch_array()[0]) {
      // Connect the url to the feed if it isn't already
      $dbConn->query("CALL connectEntry('$url', '$feedID')");
      return true;
    }
    return false;
  }
  
}

 ?>
