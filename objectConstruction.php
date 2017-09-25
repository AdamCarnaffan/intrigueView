<?php 

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

class SiteData {
  
  public $siteIcon;
  public $siteURL; 
  public $siteId; 
  public $feedId; 
  public $imageURL; 
  public $synopsis;
  public $pageContent; 
  
  public function __construct($url, $feedId, $dbConn) {
    $this->feedId = $feedId; // PLACEHOLDER FOR FEED DATA SUBMISSION
    // Get the contents of the site page
    $this->pageContent = $this->getPageContents($url);
    if ($this->pageContent == null) {
      throw new Exception("The URL is invalid or the page does not accept outside requests");
    }
    // get the Site URL for a cross check with the database
    $this->siteURL = explode("/",$url)[2];
    // Check for the site URL in the database sites table
    $getSiteInfo = "SELECT `icon`,`site_id` FROM `sites` WHERE `url` = '$this->siteURL'";
    if ($tempInfo = $dbConn->query($getSiteInfo)) { // Check that the query is successful
      $siteResult = $tempInfo->fetch_array();
      if (count($siteResult) > 0) { // Check for the return of a result
        $this->siteIcon = null; // If the site is already in the database, the site icon does not matter
        $this->siteId = $siteResult['site_id'];
      } else {
        // Get the site icon from the contents
        $this->siteIcon = $this->validateImageLink($this->getSiteIconURL($this->pageContent));
        // Submit the site to the database as a new site entry
        $insertSite = "INSERT INTO `sites` (`url`,`icon`) VALUES ('$this->siteURL','$this->siteIcon')";
        if ($dbConn->query($insertSite)) {
          $this->siteId = $dbConn->insert_id;
        } else {
          throw new Exception($dbConn->error);
        }
      }
    } else {
      throw new Exception($dbConn->error);
    }
    // Find the feature image on the page
    $this->imageURL = $this->validateImageLink($this->getImage($this->pageContent));
    // Get an excerpt of text from the article to display if no feature image is found
    $this->synopsis = trim(addslashes($this->getExcerpt($this->pageContent)));
  }
  
  public function getImage($pageContent) {
    // Check for schema.org inclusion (this is used to determine compatibility)
    if (strpos($pageContent, 'schema.org"') !== false) {
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
          $imageURL = explode('"',$honedURL)[2];
          return $imageURL;
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
    } elseif (strpos($pageContent, "og:image") !== false) { // Cover Wikipedia articles which never use schema.org but are common
      $contentsTrim = substr($pageContent, strpos($pageContent, "og:image"), 600);
      $imageURL = explode('"',$contentsTrim)[2];
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
      $urlPos = strpos($imgURL, "image_uri");
      $cdnLinkNoEnd = substr($imgURL, $urlPos);
      $cdnLink = explode('&',$cdnLinkNoEnd)[0];
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
    // Interpret all /'s final 
    $imgURL = str_replace('%2F', '/', $imgURL);
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
    $linkTagSelection = explode("<link",$pageContents);
    array_shift($linkTagSelection);
    foreach ($linkTagSelection as $tag) {
      $rel = substr($tag, strpos($tag, 'rel="'), 25);
      if (strpos($rel, "icon") !== false) {
        $iconURL = explode('href="', $tag)[1];
        $iconURL = explode('"', $iconURL)[0];
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
}

//echo htmlspecialchars($pageInfo->imageURL); // AS String
//echo "<img src='" . getImage($pageURL) . "' />"; // AS Image

class User {
  
  public $id;
  public $name;
  public $permissions = [];
  
  public function __construct($id, $dbConn, $username) {
    $this->id = $id;
    $this->name = $username;
    $getPerms = "SELECT permission_id, feed_id FROM user_permissions WHERE user_id = '$this->id'";
    if ($result = $dbConn->query($getPerms)) {
      while ($row = $result->fetch_array()) {
        $tempPerm = new Permission($row[0],$row[1]);
        array_push($this->permissions, $tempPerm);
      }
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
  
  public function __construct($feedId, $dbConn) {
    $this->id = $feedId;
    $sourceQuery = "SELECT `url`,`title` FROM `feeds` WHERE `feed_id` = '$this->id'";
    if ($result = $dbConn->query($sourceQuery)) {
      $sourceInfo = $result->fetch_array();
    } else {
      throw new exception($conn->error);
    }
    $this->source = $sourceInfo['url'];
    $this->title = $sourceInfo['title'];
  }
  
}



 ?>
