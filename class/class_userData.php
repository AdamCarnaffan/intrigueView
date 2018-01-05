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
  
  private $viewCount; // Tracks the number of views since last recommendation set
  
  public function __construct(mysqli $dbConn, $userData = null) {
    if (is_null($userData)) {
      // Create a temporary user for the guest
      $this->id = uniqid(); // Generate a session ID for temp table
      $this->isTempt = true;
    } else {
      // Login a full user
      $this->name = $userData['username'];
      $this->feed = $userData['feedID']; // The user's personal Feed ID
      $this->id = $userData['id'];
      $this->getPerms($dbConn);
      $this->getSubs($dbConn);
      $this->generateRecommendations($dbConn);
    }
    // Generate a recommendation table to tailor to the user
    
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
      $this->adjustRecommendations($conn);
      $this->viewCount = 0;
    }
  }

  public function generateRecommendations(mysqli $conn) {
    // Get views from table for users if available
    if (count($this->recentViews) < 10 && !$this->isTemp) {
      $result = $conn->query("SELECT entryID FROM user_views WHERE userID = '$this->id' ORDER BY viewTime DESC LIMIT 10");
      while ($row = $result->fetch_array()) {
        array_push($this->recentViews, new Entry($row[0], $dbConn));
      }
    }
    // generate recommendations with recent views
  }
  
  public function adjustRecommendations(mysqli $conn) {
    // Check for any changes in the viewed entries and adjust recommendations to match that
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
