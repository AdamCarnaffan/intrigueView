<?php

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

function validateImageLink($imgURL) {
  // Make a library of supported extensions
  $supportedExtensions = ['bmp','jpg','jpeg','png','gif','webp','ico'];
  // Interpret URL if it is from a URI scheme
  do {
    $imgURL = str_replace('%25','%',$imgURL); // Interpret percentage signs
    if (false !== strpos($imgURL, "image_uri")) {
      // The Distribution takes place through a routed network, the true URL is embedded
      $urlPos = strpos($imgURL, "image_uri");
      $cdnLinkNoEnd = substr($imgURL, $urlPos);
      $cdnLink = explode('&',$cdnLinkNoEnd)[0];
      $embedded = true;
    } else {
      // The Distribution is not through a routed CDN
      $cdnLink = $imgURL;
      $embedded = false;
    }
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
  if ($embedded) {
    // Interpret all /'s final
    $imgURL = str_replace('%2F', '/', $imgURL);
    return $imgURL;
  }
  // Change all slashes before checking
  $imgURL = str_replace('%2F', '/', $imgURL);
  // Check for embedded 'smart' links
  if (substr_count($imgURL, "http://") > 1 || substr_count($imgURL, "https://") > 1) {
    $lastURLPos = strrpos($imgURL, "http://");
    $lastURLPos = ($lastURLPos != 0) ? $lastURLPos : strrpos($imgURL, "https://");
    $fullURL = substr($imgURL, $lastURLPos);
    $fullURL = str_replace('%3F', '&', $fullURL);
    $imgURL = explode('&', $fullURL)[0];
  }
  // Breakdown the URL for the file extension (as the extension is of an unknown length)
  $breakdownForExtension = explode(".",$imgURL);
  $extension = $breakdownForExtension[count($breakdownForExtension) - 1];
  //Protect extension validation from addition image properties on the image URL
  $extension = trim(explode("?",$extension)[0]);
  // Validate the extension or return null for the URL if the extension is invalid
  $validURL = (in_array(strtolower($extension), $supportedExtensions)) ? $imgURL : null;
  return $validURL;
}

function stripScripting($contents) {
  return preg_replace("/<script\b[^>]*>(.*?)<\/script>/is", " ", $contents);
}

function stripHTMLTags($contents) {
  // Find and remove any script from the excerpt (scripting happens inbetween tags and isn't caught by the other method)
  $contentNoScript = stripScripting($contents);
  // Remove Styling info
  $contentNoStyling = preg_replace("/<style\b[^>]*>(.*?)<\/style>/is", " ", $contentNoScript);
  // Remove html tags and formatting from the excerpt
  $contentNoHTML = preg_replace("#\<[^\>]+\>#", " ", $contentNoStyling);
  // Clean additional whitespaces
  return preg_replace("#\s+#", " ", $contentNoHTML);
}

function stripPunctuation($string) {
  $punctuation = ['?', ".", "!", ",", "-", '"', "&quot;", "]", "[", "(", ")", "'s", "&#x27;s"];
  // Replace dashes with spaces to separate words
  $wordConnectors = ['—', '-'];
  $string = str_replace($wordConnectors, " ", $string);
  return str_replace($punctuation, "", $string);
}

function fixHTMLChars($string) {
  $fixed = str_replace("&quot;", '"', $string);
  return $fixed;
}

?>
