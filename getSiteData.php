<?php
// Site Data Object to return (include site icon url, image url, synopsis)

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
    $this->synopsis = addslashes($this->getExcerpt($this->pageContent));
  }
  
  public function getImage($pageContent) {
    // Check for schema.org inclusion (this is used to determine compatibility)
    if (strpos($pageContent, 'schema.org"') !== false) {
      // Remove whitespaces for uniformity of string searches
      $noWhiteContent = str_replace(' ','',$pageContent);
      // Select the beginning position of the required section
      $beginningPos = strpos($noWhiteContent, '"@context":"http://schema.org"');
      // Find the end and create a string that includes only required properties
      $contentsTrim = substr($noWhiteContent, $beginningPos, strpos($noWhiteContent,'</script>', $beginningPos) - $beginningPos);
      // Select each instance of ":{" --> if it is preceeded by "image", it contains the image url.
      $nextContainsURL = false; // Define the variable to prevent exceptions
      foreach (explode(":{",$noWhiteContent) as $segment) {
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
        return $iconURL;
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
    // Remove html tags and formatting from the excerpt
    $excerptClean = preg_replace("#\<[^\>]+\>#", " ", $excerptTagged);
    // Check that the excerpt contains content
    if (!array_intersect(str_split($excerptClean), range('a','z'))) {
      if ($attempt > 10) { // Timeout for attempting to get excerpt
        return null;
      }
      $attempt++;
      goto start;
    }
    return $excerptClean;
  }
  
  public function clearData() {
    $this->imageURL = null; 
    $this->synopsis = " ";
    $this->pageContent = null; 
  }
}

//echo htmlspecialchars($pageInfo->imageURL); // AS String
//echo "<img src='" . getImage($pageURL) . "' />"; // AS Image

?>
