<?php

class User {

  public $id;
  public $name;
  public $permissions = [];
  public $feed;
  public $subscriptions;
  public $recentViews = [];

  public function __construct(mysqli $dbConn, $userData = null) {
    if (is_null($userData)) {
      // Create a temporary user for the guest
      $this->id = uniqid(); // Generate a session ID for temp table
    } else {
      // Login a full user
      $this->name = $userData['username'];
      $this->feed = $userData['feedID']; // The user's personal Feed ID
      $this->id = $userData['id'];
      $this->getPerms($dbConn);
      $this->getSubs($dbConn);
      // Get current most recent views
      // Push query results to this->recentViews
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
  
  public function view($conn) {
    // Add the view to the tracking table if the userID is permanent
    // Track the view in a local array
    // Adjust recommendations every third view
  }

  public function generateRecommendations($conn) {
    // generate recommendations with recent views
  }
  
  public function adjustRecommendations($conn) {
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
