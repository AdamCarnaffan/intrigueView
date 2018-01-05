<?php

require_once('functions_dependent.php');

class Source_Site {

  public $url;
  public $id;
  public $icon;

  public function __construct($reference, $dbConn = null) {
    if (is_array($reference)) { // Get the data from the DB array
      $this->id = isset($reference['siteID']) ? $reference['siteID'] : null;
      $this->url = $reference['url'];
      $this->icon = $reference['icon'];
    } else if (is_numeric($reference)) { // Do the fetch by DB ID (Query Method)
      $this->id = $reference;
      if (is_null($dbConn)) {
        throw new Exception ("A Database Connection Object (MySQLI Object) is required to fetch by ID for '{$reference}'");
      }
      if ($result = $dbConn->query("SELECT url, icon FROM sites WHERE siteID = '$this->id' LIMIT 1")->fetch_array()) {
        $this->url = $result[0];
        $this->icon = $result[1];
      }
    } else { // Set the URL
      if (strlen($reference) > 2) {
        $this->url = $reference;
      } else {
        throw new Exception ("The following Source Site reference is invalid: '{$reference}' ");
      }
    }
  }

  public function getData(mysqli $dbConn, $siteContent = null) {
    // Check the DB for the URL
    if ($returnData = $dbConn->query("SELECT siteID, icon FROM sites WHERE url = '$this->url' LIMIT 1")->fetch_array()) {
      $this->id = $returnData[0];
      $this->icon = $returnData[1];
      return;
    }
    // Fetch the info if not available
    if (is_null($siteContent)) {
      $pageContent = getPageContents($this->url);
    } else {
      $pageContent = $siteContent;
    }
    $this->icon = validateImageLink($this->getPageIcon($pageContent));
    // Submit to database
    if ($dbConn->query("INSERT INTO sites (url, icon) VALUES ('$this->url','$this->icon')")) {
      $this->id = $dbConn->insert_id;
    } else {
      throw new Exception($dbConn->error);
    }
    return;
  }

  public function getPageIcon($pageContents) {
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
        $iconURLFinal = $this->fixURLPathing($iconURL);
        return $iconURLFinal;
      } elseif (strpos($tag, "'icon'") !== false) { // Use the single quotation mark in the case where it is used in the rel
        $iconURL = explode("href='", $tag)[1];
        $iconURL = explode("'", $iconURL)[0];
        $iconURLFinal = $this->fixURLPathing($iconURL);
        return $iconURLFinal;
      }
    }
    return null;
  }

  public function fixURLPathing($url) {
    if (substr(strtolower($url), 0, 4) != 'http') {
      $urlNew = "http://" . $this->url . $url;
      return $urlNew;
    } else {
      return $url;
    }
  }

}

class Entry {

  public $source;
  public $id;
  public $title;
  public $url;
  public $image;
  public $synopsis;
  public $tags = [];

  public function __construct($data, $dbConn) {
    // Handle an Entry ID being passed to the constructor
    if (is_int($data)) {
      // Clean this up
      $entryID = $data;
      $data = $dbConn->query("SELECT title, siteID, url, featureImage, previewText FROM entries WHERE entryID = '$entryID'")->fetch_array();
      $data['entryID'] = $entryID;
    } 
    // Begin building the object
    if (is_array($data)) {
      $this->source = new Source_Site($data['siteID'], $dbConn);
      $this->title = $data['title'];
      $this->url = $data['url'];
      $this->image = $data['featureImage'];
      $this->synopsis = $data['previewText'];
      $this->id = $data['entryID'];
      $this->fetchTags($dbConn);
    } else {
      throw new Exception("An ID or Entry Data Package is required to build an Entry where '$data' was provided");
    }
  }

  public function fetchTags($dbConn) {
    $tagQuery = $dbConn->query("SELECT tags.tagName, tags.tagID FROM entry_tags AS tagConn JOIN tags ON tags.tagID = tagConn.tagID WHERE entryID = '$this->id' ORDER BY tagConn.sortOrder DESC");
    while ($data = $tagQuery->fetch_array()) {
      array_push($this->tags, new Tag($data[0], $data[1]));
    }
    return;
  }

  public function updateEntry(Entry $newInfo, $dbConn) {
    // Update Entry Data
    $this->url = $newInfo->url;
    $this->synopsis = $newInfo->synopsis;
    $this->image = ($newInfo->image != null) ? $newInfo->image : $this->image;
    $this->title = $newInfo->title;
    $dbConn->query("UPDATE entries SET url = '$this->url', title = '$this->title', featureImage = '$this->image', previewText = '$this->synopsis' WHERE entryID = '$this->id'");
    // Determine new tags
    $newTags = [];
    $newEntryTags = [];
    foreach ($newInfo->tags as $tagObject) {
      array_push($newEntryTags, $tagObject->name);
    }
    $prevTags = [];
    foreach ($this->tags as $tagObject) {
      array_push($prevTags, $tagObject->name);
    }
    $newTags = array_diff($newEntryTags, $prevTags);
    // Get the current sort order position
    $sortOrder = $dbConn->query("SELECT sortOrder FROM entry_tags WHERE entryID = '$this->id' ORDER BY sortOrder DESC LIMIT 1")->fetch_array()[0];
    // Add the tags
    foreach ($newTags as $tag) {
      $sortOrder++;
      $dbConn->query("CALL addTag('$tag', '$this->id', '$sortOrder')");
    }
    return;
  }

}

class Tag {

  public $name;
  public $databaseID;

  public function __construct($tagName, $dbID = null) {
    $this->name = $tagName;
    $this->databaseID = $dbID;
  }

  public function checkPluralization() {
    if (strpos($this->name, "s", -1) !== false || strpos($this->name, "i", -1) !== false) {
      return true;
    }
    return false;
  }

  public function generateTagSingulars() {
    $singularStrings = [];

    // Add the tag without an s as the first possible singlular form
    $tempSingleSplit = str_split($this->name);
    array_pop($tempSingleSplit);
    // Check for a pluralized acronym, skip if so
    if (ctype_upper(implode($tempSingleSplit))) {
      return false;
    }
    array_push($singularStrings, implode($tempSingleSplit));

    // Add other possible pluralizations of the word

    // i -> us ex. cacti = cactus
    if (strpos($this->name, "i", -1) !== false) {
      $tempSingleSplit = str_split($this->name);
      $tempSingleSplit[count($tempSingleSplit) - 1] = "us";
      array_push($singularStrings, implode($tempSingleSplit));
    }

    // ies -> ex. entries = entry
    if (strlen($this->name) > 3 && strpos($this->name, "s", -1) !== false) {
      if (strpos($this->name, "ies", -4)) {
        $tempSingleSplit = str_split($this->name);
        // Remove last 2 characters from array
        array_pop($tempSingleSplit);
        array_pop($tempSingleSplit);
        $tempSingleSplit[count($tempSingleSplit) - 1] = "y";
      }
    }
    return $singularStrings;
  }

  public function consolidate($dbConn) {
    /**
    * Returning false indicated that no consolidation was available (the inverse indicated the inverse)
    *
    * @param (mysqli object) $dbConn -> MySQL database connection object for queries
    */

    // Check that the tag name appears to be a plural form
    if (!$this->checkPluralization()) {
      return false;
    }
    // Don't even bother if the tag is an acronym
    if (ctype_upper($this->name)) {
      return false;
    }
    // Generate possible singulars
    $possibleSingulars = $this->generateTagSingulars();
    // Develop a query to find existing IDs
    $transitionString = "";
    // Begin query definition
    $getSingle = "SELECT tagID, tagName FROM tags WHERE ";
    foreach ($possibleSingulars as $tagName) {
      $getSingle .= "tagName = '{$tagName}'";
      $transitionString = " OR ";
    }
    // Return only one result, the result to which other tags should link
    $getSingle .= " LIMIT 1";

    // Run the query
    if ($existingID = $dbConn->query($getSingle)->fetch_array()) {
      // Sets the information for the tag equal to the existing singular tag
      $this->databaseID = $existingID[0];
      $this->name = $existingID[1];
      return true; // A single was found
    } else {
      return false; // Indicate that no single currently exists
    }
  }

}

?>
