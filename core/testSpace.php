<?php 

$txt = getPageContents("https://lifehacker.com/check-if-your-android-vpn-is-collecting-personal-data-1833108243");
$img = Meta::extractSchema($txt);
print_r( $img);

class Meta {
  
  public $name;
  public $value;
  
  public function __construct($name, $value) {
    $this->name = $name;
    $this->value = $value;
  }
    
  public static function extractMeta($pageContent) {
    $allMeta = explode("<meta ", $pageContent);
    array_shift($allMeta);
    $data = [];
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
        if (strpos($ln, "name=") !== false || strpos($ln, "property=") !== false) {
          $nm = $dt[$ind+1];
        } else if (strpos($ln, "content=") !== false || strpos($ln, "value=") !== false) {
          $val = $dt[$ind+1];
        }
      }
      $meta = new Meta($nm, $val);
      if ($meta->name == null || $meta->value == null) {
        continue;
      } else { array_push($data, $meta); }
    }
    return $data;
  }
  
  public static function extractSchema($pageContent) {
    $scrpts = explode("<script", $pageContent);
    $schem = null;
    $data = [];
    foreach ($scrpts as $scr) {
      if (($ps = strpos($scr, "schema.org")) !== false) {
        if ($ps < strpos($scr, "</script>")) {
          $schem = $scr;
          break;
        }
      }
    }
    if ($schem == null) {
      return $data;
    }
    $schem = explode("</script>", $schem)[0];
    $schem = explode(">", $schem, 2)[1];
    return $this->interpretSchema($schem);
  }
  
  private function interpretSchema($schem) {
    // Take from schema string to Meta object
    
  }
}

function getPageContents($url) {
  // Run a query to the page for source contents
  $pageContents = @file_get_contents($url);
  // If the url cannot be accessed, make another attempt as a user
  if ($pageContents == null || $pageContents == false) {
    $pageContents = getContentsAsUser($url);
    if ($pageContents == null) {
      return null;
    }
  }
  return $pageContents;
}

function getContentsAsUser($url) {
  // Mimic a user browser request to work around potential 401 FORBIDDEN errors
  $userAgent = 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36';
  // Instantiate and configure a cURL to mimic a user request (uses the cURL library)
  $curl = curl_init();
  curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, false);
  curl_setopt($curl, CURLOPT_VERBOSE, true);
  curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
  curl_setopt($curl, CURLOPT_USERAGENT, $userAgent);
  curl_setopt($curl, CURLOPT_URL, $url);
  // Run a query to the page for source contents using a viewer context
  $pageContents = curl_exec($curl);
  // If the page content is still null following this, the site is unreachable, null should be returned
  if ($pageContents == null || $pageContents == false) {
    return null;
  }
  return $pageContents;
}

function getPageIcon($pageContents) {
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
      $iconURLFinal = fixURLPathing($iconURL);
      return $iconURLFinal;
    } elseif (strpos($tag, "'icon'") !== false) { // Use the single quotation mark in the case where it is used in the rel
      $iconURL = explode("href='", $tag)[1];
      $iconURL = explode("'", $iconURL)[0];
      $iconURLFinal = fixURLPathing($iconURL);
      return $iconURLFinal;
    }
  }
  return null;
}

function fixURLPathing($url) {
  if (substr(strtolower($url), 0, 4) != 'http') {
    $urlNew = "http://" . $url;
    return $urlNew;
  } else {
    return $url;
  }
}

 ?>
