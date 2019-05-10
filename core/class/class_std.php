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

  public function getData(mysqli $dbConn, $entryData = null) {
    // Check the DB for the URL
    if ($returnData = $dbConn->query("SELECT site_id, icon FROM sites WHERE url = '$this->url' LIMIT 1")->fetch_array()) {
      $this->id = $returnData[0];
      $this->icon = $returnData[1];
      return;
    }
    // Fetch the info if not available
    $data = (object) array();
    if (is_null($entryData)) {
      $data->pageContent = getPageContents($this->url);
      $data->schema = extractSchema($pageContent);
      $data->meta = Meta::extractMeta($pageContent);
    } else {
      $data = $entryData;
    }
    $this->getPageIcon($data);
    // Submit to database
    if ($dbConn->query("INSERT INTO sites (url, icon) VALUES ('$this->url','$this->icon')")) {
      $this->id = $dbConn->insert_id;
    } else {
      throw new Exception($dbConn->error);
    }
    return;
  }

  public function getPageIcon($pageData) {
    // Check Schema
    if ($pageData->schema != null) {
      if (property_exists($pageData->schema, "logo")) {
        if (is_array($pageData->schema->logo)) {
          $this->icon = $this->fixURLPathing(validateImageLink($pageData->schema->logo[0]->url));
        } else {
          $this->icon = $this->fixURLPathing(validateImageLink($pageData->schema->logo->url));
        }
        return;
      }
    }
    // Check Meta inclusion
    if ($pageData->meta != null) {
      // Check higher res first
      foreach ($pageData->meta as $dat) {
        if ($dat->name == "logo" || $dat->name == "icon") {
          $this->icon = $this->fixURLPathing(validateImageLink($dat->value));
          return;
        }
      }
      // Then get backups
      foreach ($pageData->meta as $dat) {
        if ($dat->name == "shortcut icon" || $dat->name == "apple-touch-icon") {
          $this->icon = $this->fixURLPathing(validateImageLink($dat->value));
          return;
        }
      }
    }
    $this->icon = null;
    return;
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

class Entry_Base {
  
  public $source;
  public $id;
  public $title;
  public $url;
  public $image;
  
  public function __construct($data) {
    if (is_array($data)) {
      $this->source = new Source_Site(["icon"=>$data['icon'], "url"=>$data['site_url']], null);
      $this->title = $data['title'];
      $this->url = $data['url'];
      $this->image = $data['thumbnail'];
      $this->id = $data['entry_id'];
    } else {
      throw new Exception("An Entry Data Package is required to build an Entry where '$data' was provided");
    }
  }
  
  public function build_tile($isRecommended) {
    $tile = "<div class='tile-wrapper'><div class='tile'><div class='tile-title'>";
    $tile .= "<a class='tile-link tile-url' onclick='return open_in_tab(\"" . $this->url . "\")' href='#'>";
    $tile .= $this->title . "</a></div><div class='tile-specifics'>";
    $tile .= "<img class='tile-site-icon' src='" . $this->source->icon . "'>";
    $tile .= "<a class='tile-site-link tile-link' onclick='return open_in_tab(\"https://" . $this->source->url;
    $tile .= "\")' href='#'>" . $this->source->url . "</a></div>";
    $tile .= "<a class='tile-image-wrapper tile-details' onclick='return get_entry_details(this, ";
    $tile .= $this->id . ")' href='#'><div class='tile-image-wrapper'>";
    $tile .= "<img class='tile-image' src='" . $this->image . "'>";
    $tile .= "</div></a></div></div>";
    return $tile;
    /*
    <div class='tile-wrapper tile-sm'>
      <div class='tile'>
        <div class='tile-title'>
          <a class='tile-link tile-url' onclick='return open_in_tab(ARTICLE URL)' href='#'>This is an article title</a>
        </div>
        <div class='tile-specifics'>
          <img class='tile-site-icon' src='assets/rss-icon.png'>
          <a class='tile-site-link tile-link' onclick='return open_in_tab(WEBSITE URL)' href='#'>www.website.com</a>
        </div>
        <a class='tile-image-wrapper tile-details' onclick='return get_entry_details(this, ENTRYID)' href='#'>
          <div class='tile-image-wrapper'>
            <img class='tile-image' src='ARTICLE IMAGE'>
          </div>
        </a>
      </div>
    </div>
    */
  }
  
}

class Entry extends Entry_Base {

  public $synopsis;
  public $tags = [];

  public function __construct($data, $dbConn) {
    // Handle an Entry ID being passed to the constructor
    if (is_int($data) || is_string($data)) {
      // Clean this up
      $entryID = $data;
      $entryQuery = "SELECT ent.title, ent.site_id, ent.url, ent.thumbnail, ent.synopsis, sites.url AS site_url, sites.icon 
                      FROM entries AS ent
                      JOIN sites ON ent.site_id = sites.site_id
                      WHERE entry_id = '$entryID' LIMIT 1";
      $data = $dbConn->query($entryQuery)->fetch_array();
      if ($data == null) { throw new Exception("The entry could not be found with entry ID $entryID"); }
      $data['entry_id'] = $entryID;
    }
    // Begin building the object
    if (is_array($data)) {
      parent::__construct($data);
      $sourceData = ["site_id"=>$data['site_id'], "icon"=>$data['icon'], "url"=>$data['site_url']];
      $this->source = new Source_Site($sourceData, null);
      $this->synopsis = $data['synopsis'];
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
    // print_r($newTags);
    foreach ($newTags as $tag) {
      $sortOrder++;
      $callStr = "CALL addTag('$tag', '$this->id', '$sortOrder')";
      $dbConn->query($callStr);
      echo "Added {$tag} </br>";
    }
    return;
  }

}

class Meta {
  
  public $name;
  public $value;
  
  public function __construct($name, $value) {
    $this->name = $name;
    $this->value = $value;
  }
    
  public static function extractMeta($pageContent) { // Returns list of metas
    // clean content of script
    $pageContent = stripScripting($pageContent);
    // echo $pageContent;
    // Examine tags
    $allMeta = explode("<meta", $pageContent);
    array_shift($allMeta);
    $allLink = explode("<link", $pageContent);
    array_shift($allLink);
    $data = [];
    // Process Meta Tags
    foreach ($allMeta as $metaLine) {
      $nm = null;
      $val = null;
      // Extract Line Data
      $dt = explode("'", $metaLine);
      if (count($dt) < 2) {
        $dt = explode('"', $metaLine);
      }
      $cont = false;
      foreach ($dt as $ind=>$ln) {
        if ($cont) { continue; }
        if (strpos($ln, " name=") !== false || strpos($ln, " property=") !== false || strpos($ln, " itemprop=") !== false) {
          $nm = ($ind+1 < count($dt)) ? $dt[$ind+1] : null;
        } else if (strpos($ln, " content=") !== false || strpos($ln, "value=") !== false) {
          $val = ($ind+1 < count($dt)) ? $dt[$ind+1] : null;
        }
      }
      $meta = new Meta($nm, $val);
      if ($meta->name == null || $meta->value == null) {
        continue;
      } else { array_push($data, $meta); }
    }
    // Process Link tags
    foreach ($allLink as $linkLine) {
      $nm = null;
      $val = null;
      // Extract Line Data
      $dt = explode("'", $linkLine);
      if (count($dt) < 2) {
        $dt = explode('"', $linkLine);
      }
      $cont = false;
      foreach ($dt as $ind=>$ln) {
        if ($cont) { $cont = false; continue; }
        if (strpos($ln, " rel=") !== false || strpos($ln, " itemprop=") !== false) {
          $nm = ($ind+1 < count($dt)) ? $dt[$ind+1] : null;
          $cont = true;
        } else if (strpos($ln, " href=") !== false) {
          $val = ($ind+1 < count($dt)) ? $dt[$ind+1] : null;
          $cont = true;
        }
      }
      $meta = new Meta($nm, $val);
      if ($meta->name == null || $meta->value == null) {
        continue;
      } else { array_push($data, $meta); }
    }
    // Filter array to make unique name for meta
    $final = [];
    foreach ($data as $met) {
      $fnd = false;
      foreach ($final as $v) {
        if ($v->name == $met->name) {$fnd = true; break;}
      }
      if (!$fnd) {array_push($final, $met);}
    }
    return $final;
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
