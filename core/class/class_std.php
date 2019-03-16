<?php

require_once(ROOT_PATH . '/class/functions_dependent.php');

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
      if ($result = $dbConn->query("SELECT url, icon FROM sites WHERE site_id = '$this->id' LIMIT 1")->fetch_array()) {
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
    if ($returnData = $dbConn->query("SELECT site_id, icon FROM sites WHERE url = '$this->url' LIMIT 1")->fetch_array()) {
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
    if (is_int($data) || is_string($data)) {
      // Clean this up
      $entryID = $data;
      $data = $dbConn->query("SELECT title, site_id, url, thumbnail, synopsis FROM entries WHERE entry_id = '$entryID' LIMIT 1")->fetch_array();
      $data['entry_id'] = $entryID;
    }
    // Begin building the object
    if (is_array($data)) {
      $this->source = new Source_Site($data['site_id'], $dbConn);
      $this->title = $data['title'];
      $this->url = $data['url'];
      $this->image = $data['thumbnail'];
      $this->synopsis = $data['synopsis'];
      $this->id = $data['entry_id'];
      // $this->views = $data['views'];
      $this->fetchTags($dbConn);
    } else {
      throw new Exception("An ID or Entry Data Package is required to build an Entry where '$data' was provided");
    }
  }

  public function fetchTags($dbConn) {
    $tagQuery = $dbConn->query("SELECT tags.tag, tags.tag_id FROM entry_tags AS tagConn JOIN tags ON tags.tag_id = tagConn.tag_id WHERE entry_id = '$this->id' ORDER BY tagConn.sort_order ASC");
    while ($data = $tagQuery->fetch_array()) {
      array_push($this->tags, new Tag($data[0], $data[1]));
    }
    return;
  }

  public function updateEntry(Entry $newInfo, mysqli $dbConn) {
    // Update Entry Data
    $this->url = $newInfo->url;
    $this->synopsis = $newInfo->synopsis;
    $this->image = ($newInfo->image != null) ? $newInfo->image : $this->image;
    $this->title = $newInfo->title;
    try {
      $upd = "UPDATE entries SET url = '$this->url', title = '$this->title', thumbnail = '$this->image', synopsis = '$this->synopsis' WHERE entry_id = '$this->id'";
      if (!$dbConn->query($upd)) {
        throw new exception($conn->error);
      } else {
        $logErr = "Updating the entry succeeded";
        $dbConn->query("INSERT INTO entry_log (entry_id, status, success) VALUES ('$this->id', '$logErr', 1)");
      }
    } catch (exception $e) {
      $logErr = $conn->real_escape_string("Adding the entry to the database failed on url: {$item->link} by -> {$e}");
      $dbConn->query("INSERT INTO entry_log (entry_id, status, success) VALUES (NULL, '$logErr', 0)");
    }
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
    $sortOrder = $dbConn->query("SELECT sort_order FROM entry_tags WHERE entry_id = '$this->id' ORDER BY sort_order DESC LIMIT 1")->fetch_array()[0];
    // Add the tags
    print_r($newTags);
    foreach ($newTags as $tag) {
      $sortOrder++;
      $callStr = "CALL addTag('$tag', '$this->id', '$sortOrder')";
      $dbConn->query($callStr);
      echo "Added {$tag} </br>";
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
    if (strlen($this->name) == 0) { // Check that the string exists
      return false;
    }
    if (strpos($this->name, "s", -1) !== false || strpos($this->name, "i", -1) !== false) {
      // Check that the string length is greater than 2, otherwise likely not a plural
      if (strlen($this->name) < 3) {
        return false;
      } else {
        return true;
      }
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
      return [];
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
    $tagList = implode("','", $possibleSingulars);
    // Begin query definition
    $getSingle = "SELECT tagID, tagName FROM tags WHERE tagName IN ('$tagList')";
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

class Feed {

  public $title;
  public $source;
  public $id;

  public function __construct($feedId, $dbConn) {
    $this->id = $feedId;
    $sourceQuery = "SELECT url, title FROM feeds WHERE feed_id = '$this->id' AND active = 1";
    if ($result = $dbConn->query($sourceQuery)) {
      $sourceInfo = $result->fetch_array();
    } else {
      throw new exception($dbConn->error);
    }
    $this->source = $sourceInfo['url'] ?? null;
    $this->title = $sourceInfo['title'] ?? "No title provided";
  }

  public function fetchXML() {
    $curl_obj = curl_init();
    curl_setopt($curl_obj, CURLOPT_RETURNTRANSFER, 1);
    curl_setopt($curl_obj, CURLOPT_URL, $this->source); // Set target
    $data = curl_exec($curl_obj); // execute request
    // Check for curl errors
    if (curl_error($curl_obj)) {
      throw new exception(curl_error($curl_obj));
    }
    curl_close($curl_obj); // Cleanup
    return simplexml_load_string($data);
  }

  public function checkBusy($dbConn) {
    $checkBusyQuery = "SELECT feed_id FROM feed_recordlocks WHERE feed_id = '$this->id' AND
                        time_set BETWEEN DATE_ADD(NOW(), INTERVAL -60 MINUTE) AND NOW()";
    if ($dbConn->query($checkBusyQuery)->fetch_array()) {
      return true;
    } else {
      return false;
    }
  }

  public function lock($dbConn) {
    $busyFeed = "INSERT INTO feed_recordlocks (feed_id) VALUES ('$this->id')";
    if (!$dbConn->query($busyFeed)) {
      throw new exception($dbConn->error);
    }
    return;
  }

  public function release($dbConn) {
    $releaseFeed = "DELETE FROM feed_recordlocks WHERE feed_id = '{$this->id}'";
    if (!$dbConn->query($releaseFeed)) {
      throw new exception($dbConn->error);
    }
    return;
  }
}

?>
