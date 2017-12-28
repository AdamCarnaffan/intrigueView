<?php

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


?>
