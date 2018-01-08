<?php

require_once('class_std.php');

class User {

  public $id;
  public $name;
  public $isTemp = false; // Determine if this is a permanent user
  public $permissions = [];
  public $feed;
  public $subscriptions;
  public $recentViews = [];
  public $recommendations = [];
  public $recommendationFocus = []; // Used to adjust recommendations
  public $recommendationAvoid = [];

  private $viewCount; // Tracks the number of views since last recommendation set

  public function __construct(mysqli $dbConn, $userData = null) {
    if (is_null($userData)) {
      // Create a temporary user for the guest
      $this->id = "temp_" . uniqid(); // Generate a session ID
      $this->isTemp = true;
      $this->generateRecommendations($dbConn);
    } else {
      // Login a full user
      $this->name = $userData['username'];
      $this->feed = $userData['feedID']; // The user's personal Feed ID
      $this->id = $userData['id'];
      $this->getPerms($dbConn);
      $this->getSubs($dbConn);
      $this->generateRecommendations($dbConn);
    }
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

  public function view(Entry $entry, mysqli $conn) {
    if (!$this->isTemp) {
      // Add the view to the user view tracker
      $conn->query("INSERT INTO user_views (userID, entryID) VALUES ('$this->id', '$entry->id')");
    }
    // Track the view in a local array
    array_push($this->recentViews, $entry);
    // Adjust recommendations every third view
    $this->viewCount++;
    if ($this->viewCount >= 3) {
      $this->generateRecommendations($conn);
      $this->viewCount = 0;
    }
  }

  public function provideFeedback(int $entryID, mysqli $conn, $disposition) {
    // Determine if an entry type is to be avoided or focused
    if (!$this->isTemp) {
      $sqlBool = ($disposition) ? 1 : 0;
      $conn->query("INSERT INTO user_feedback (userID, entryID, preference) VALUES ('$this->id', '$entryID', '$sqlBool')");
    }
    if ($disposition) {
      array_push($this->recommendationFocus, $entryID);
    } else {
      array_push($this->recommendationAvoid, $entryID);
    }
  }

  private function determineFeedbackTrends(mysqli $conn) {
    // Use the entries to determine a trend in user likes & dislikes
  }

  public function generateRecommendations(mysqli $conn) {
    // Recent the array for a new generation
    $this->recommendations = [];
    // Begin building recommendations
    if ($this->isTemp) {
      // Build a list of entryIDs from recent views array
      $tempRecentArray = [];
      foreach ($this->recentViews as $entry) {
        array_push($tempRecentArray, $entry->id);
      }
    }

    // Get views from table for users if available
    if (count($this->recentViews) < 10 && !$this->isTemp) {
      $result = $conn->query("SELECT entryID FROM user_views WHERE userID = '$this->id' ORDER BY viewTime DESC LIMIT 10");
      while ($row = $result->fetch_array()) {
        array_push($this->recentViews, new Entry($row[0], $dbConn));
      }
    }
    // Generate a short recent entries list for temp users or new accounts
    $recentEntries = (isset($tempRecentArray) && count($tempRecentArray) > 0) ? implode("','", $tempRecentArray) : "";
    if (count($this->recentViews) < 10) {
      // Use a completely different query for general recommendations
      // View number should be scaled based on average views of an entry
      $recomQuery = "SELECT entryID, (CASE WHEN datePublished BETWEEN DATE_ADD(NOW(), INTERVAL -2 DAY) AND NOW() THEN 1 ELSE 0 END) AS veryRecent FROM entries
                      WHERE datePublished BETWEEN DATE_ADD(NOW(), INTERVAL -40 DAY) AND NOW() AND entryID NOT IN ('$recentEntries')
                      ORDER BY veryRecent DESC, views DESC, datePublished DESC";
    } else {
      // generate recommendations with recent views
      // Get the tags from the last 10 articles viewed (general preference coming soon)
      $recommendationTags = [];
      for ($c = count($this->recentViews) - 1, $d = 1; $d < 11; $d++, $c--) {
        $articleTags = $this->recentViews[$c]->tags;
        foreach ($articleTags as $tag) {
          // Add the tag ID to the array or incriment its frequency if it exists
          $recommendationTags[$tag->databaseID] = isset($recommendationTags[$tag->databaseID]) ? $recommendationTags[$tag->databaseID]++ : 1;
        }
      }
      // Sort the array by the frequency of occurence of the tags
      arsort($recommendationTags);
      $tagQueryList = implode("','", $recommendationTags);
      // Get all related entries
      // Query RULES:
      //  Entry must have been published in the last 60 days
      //  The entries that are very recent (last 5 days) are prioritized
      //  If an entry has more than one of the tags, it is sorted as such based on the first tag found
      //  The entries are then sorted based on recency
      $recomQuery = "SELECT tagConn.entryID, tagConn.tagID, entries.datePublished, COUNT(tagConn.tagID),
                      (CASE WHEN entries.datePublished BETWEEN DATE_ADD(NOW(), INTERVAL -5 DAY) AND NOW() THEN 1 ELSE 0 END) AS veryRecent
                      FROM entry_tags AS tagConn
                      JOIN entries ON entries.entryID = tagConn.entryID
                      WHERE entries.datePublished BETWEEN DATE_ADD(NOW(), INTERVAL -60 DAY) AND NOW()
                      AND tagConn.tagID IN ('$tagQueryList') AND ";
      if ($this->isTemp) {
        // Use the temporary user view tracker
        $recomQuery .= "tagConn.entryID NOT IN ('$recentEntries')";
      } else {
        $recomQuery .= "tagConn.entryID NOT IN (SELECT views.entryID FROM user_views AS `views` WHERE views.userID = '$this->id')";
      }
      $recomQuery .= " GROUP BY entries.entryID
                        ORDER BY veryRecent DESC, COUNT(tagConn.tagID) DESC, FIELD(tagConn.tagID, '$tagQueryList'), entries.datePublished DESC";
    }
    // Run the query
    $result = $conn->query($recomQuery);
    $resultCount = 0;
    // Only store 50 recommendations per user (they can be regenerated fairly quickly)
    while ($data = $result->fetch_array() && $resultCount <= 50) {
      array_push($this->recommendations, $data['entryID']);
      $resultCount++;
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


?>
