<?php 
include ('dbConnect.php');

class Entry {
  
  public $feedName;
  public $title;
  public $url;
  public $image;
  public $synopsis;
  public $siteURL;
  public $siteIcon;
  public $entryDisplaySize;
  
  public function __construct($dataArray, $displayPoint) {
    // Get all data from the Query. Indexes are based on position in the query
    $this->feedName = $dataArray[0];
    $this->title = $dataArray[1];
    $this->url = $dataArray[2];
    $this->image = $dataArray[4];
    $this->synopsis = $dataArray[5];
    $this->siteURL = $dataArray[6];
    $this->siteIcon = $dataArray[7];
    echo $this->displayEntryTile($displayPoint);
  }
  
  public function displayEntryTile($entryDisplay) {
    $featuredTiles = ['1','10','21','31'];
    if (in_array($entryDisplay, $featuredTiles) || $entryDisplay % 21 == 0) { // Decide if the article will be a feature or not
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
    // Add feed tile Class
    $tile .= '<div class="feed-tile">';
    // Add Article URL
    $tile .= '<a href="' . $this->url .'" class="hover-detect"><span class="entry-url"></span></a>';
    // Add Article Heading
    $tile .= '<h5 class="entry-heading">' . $this->title . '</h5>';
    // Add Article Feature Image if available
    if ($this->image != null) {
      $tile .= '<div class="image-container"><img class="image" src="' . $this->image . '"/></div>';
    } else {
      // Add the synopsis here (STYLING INCOMPLETE)
      $synopsisExcerpt = substr($this->synopsis, 0, 270);
      if (strlen($synopsisExcerpt) == 270) {
        $synopsisExcerpt .= "...";
      }
      $tile .= '<div class="synopsis-container centered"><p class="synopsis">' . $synopsisExcerpt . '</p></div>';
    }
    // Add Site Stats
    $tile .= '<div class="entry-stats"><p class="site-info">';
    // Site Icon
    if ($this->siteIcon != null) { // Handle cases where site icons haven't fetched properly or don't exist
      $tile .= '<img src="' . $this->siteIcon . '" class="site-icon"/>';
    }
    // Site URL (hyperlink)
    $linkedURL = "http://" . $this->siteURL;
    $tile .= '<a class="site-info-url" href="' . $linkedURL . '">';
    // Site URL (visual)
    $tile .= $this->siteURL;
    // Close all required tags
    $tile .= '</a></p></div></div></div>';
    return $tile;
  }
  
  public function isFeature() {
    if ($this->entryDisplaySize == 2) {
      return true;
    } else {
      return false;
    }
  }
  
}

$selectionLimit = 25;
$entryDisplayNumber = 1; // The slot for page display (all queries return an even number of slots used)
// When changing the query, remember to adjust object indexes
$getEntries = "SELECT feed.title, entries.title, entries.url, entries.date_published, entries.feature_image, entries.preview_text, site.url, site.icon FROM `entries` JOIN `feeds` AS feed ON entries.feed_id = feed.feed_id JOIN `sites` AS site ON entries.site_id = site.site_id ORDER BY `date_published` DESC LIMIT $selectionLimit";
$result = $conn->query($getEntries);
while ($row = $result->fetch_array()) {
  $entry = new Entry($row, $entryDisplayNumber);
  if ($entry->isFeature()) {
    $entryDisplayNumber++; // Feature entries consume two slots
  }
  $entryDisplayNumber++;
}

 ?>
