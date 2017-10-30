<?php

Class Tag extends PotentialTag {
  
  public $weight;
  public $priority;
  
  public function __construct($potentialTagObject, $weighting) {
    $this->tag = $potentialTagObject->tag;
    $this->frequency = $potentialTagObject->frequency;
    $this->weight = $weighting;
  }
  
  public function prioritize() {
    $this->priority = round($this->frequency*$this->weight);
  }
}

// Author Tags --> INPUT 1
// Content Tags --> INPUT 2
// Title Tags --> INPUT 3
// URL Tags --> INPUT 4

$weightedTags = checkCommonality($authorTags, $articleTags, $titleTags, $urlTags);

$finalTags = computeWeighting($weightedTags);

print_r($finalTags);

// --------------------------------------------------------------------------------

function checkCommonality($input1, $input2, $input3, $input4) { // Hidden COL 1 ROW 1
  $author = [];
  $content = [];
  $title = [];
  $url = [];
  // Put author tags into array, forgetting weighting
  foreach ($input1 as $tagObject) {
    array_push($author, $tagObject->tag);
  }
  // Put Content tags into array, forgetting weighting
  foreach ($input2 as $tagObject) {
    array_push($content, $tagObject->tag);
  }
  // Put Title tags into array, forgetting weighting
  foreach ($input3 as $tagObject) {
    array_push($title, $tagObject->tag);
  }
  // Put URL tags into array, forgetting weighting
  foreach ($input4 as $tagObject) {
    array_push($url, $tagObject->tag);
  }
  /*
  PRIORITY LIST
  -----------------
  1) Intersections with URL
  2) Intersections with Author Tags
  3) Intersections with Title
  
  RULES
  -----------------
  -> All Author Tags are kept, though weighted lowly without intersections
  -> Title Tags are ONLY kept if they intersect with another kind of tag
  -> URL Tags are only used for this step, and are then discarded
  -> Content Tags are kept should they intersect OR appear in a Frequency above 5
  -> When writing intersections, CONTENT tags always go first to keep the index
  */
  // URL INTERSECTION
  // Check URL-Author intersection
  $outURLAuth = array_intersect(array_map('strtolower',$author), $url);
  // Check URL-Content intersection
  $outURLCont = array_intersect(array_map('strtolower',$content), $url);
  // Don't intersect URL and Title, as they are usually the same
  // AUTHOR INTERSECTION
  $outAuthCont = array_intersect($content, $author);
  $outAuthTitle = array_intersect($title, $author);
  // TITLE INTERSECTION
  $outTitleCont = array_intersect($content, $title);
  // OUTPUT INTERSECTIONS
  $outURLTotal = array_intersect($outURLCont, $outURLAuth);
  $outAuthTotal = array_intersect($outAuthCont, $outAuthTitle);
  // Output Weighting
  /* 
  TRIPLE W/ URL --> 5
  TRIPLE W/O URL --> 2
  DOUBLE W/ URL --> 2
  DOUBLE W/ Auth --> 1.3
  DOUBLE W/ Title --> 0.8
  CONTENT FREQ TOP 10% --> 0.4
  */
  // Weighting Variables
  $tripleU = 5;
  $triple = 2;
  $doubleU = 2;
  $doubleA = 1.3;
  $doubleT = 0.8;
  $contFreq = 0.4;
  // Process All Final Tags
  $tagOutput = [];
  // TRIPLE W/ URL
  foreach ($outURLTotal as $contentIndex=>$name) {
    array_push($tagOutput, new Tag($input2[$contentIndex], $tripleU));
  }
  // TRIPLE W/O URL
  foreach ($outAuthTotal as $contentIndex=>$name) {
    $exists = false;
    // Check that the tag is not already added
    foreach ($tagOutput as $tagOut) {
      if ($tagOut->tag == $name) {
        $exists = true;
        break;
      }
    }
    if (!$exists) {
      array_push($tagOutput, new Tag($input2[$contentIndex], $triple));
    }
  }
  // DOUBLE W/ URL
  foreach (array_unique(array_merge($outURLAuth, $outURLCont)) as $contentIndex=>$name) {
    $exists = false;
    // Check that the tag is not already added
    foreach ($tagOutput as $tagOut) {
      if ($tagOut->tag == $name) {
        $exists = true;
        break;
      }
    }
    if (!$exists) {
      array_push($tagOutput, new Tag($input2[$contentIndex], $doubleU));
    }
  }
  // DOUBLE W/ Author
  foreach (array_unique(array_merge($outAuthCont, $outAuthTitle)) as $contentIndex=>$name) {
    $exists = false;
    // Check that the tag is not already added
    foreach ($tagOutput as $tagOut) {
      if ($tagOut->tag == $name) {
        $exists = true;
        break;
      }
    }
    if (!$exists) {
      array_push($tagOutput, new Tag($input2[$contentIndex], $doubleA));
    }
  }
  // DOUBLE W/ Author
  foreach ($outTitleCont as $contentIndex=>$name) {
    $exists = false;
    // Check that the tag is not already added
    foreach ($tagOutput as $tagOut) {
      if ($tagOut->tag == $name) {
        $exists = true;
        break;
      }
    }
    if (!$exists) {
      array_push($tagOutput, new Tag($input2[$contentIndex], $doubleT));
    }
  }
  // TOP 10% of Content Tags
  for ($c = 0; $c <= count($input2)*0.1; $c++) {
    $exists = false;
    // Check that the tag is not already added
    foreach ($tagOutput as $tagOut) {
      if ($tagOut->tag == $input2[$c]->tag) {
        $exists = true;
        break;
      }
    }
    if (!$exists) {
      array_push($tagOutput, new Tag($input2[$c], $contFreq));
    }
  }
  return $tagOutput;
}

function computeWeighting($tags) {
  $prioritizedTags = [];
  foreach ($tags as &$tag) {
    $tag->prioritize();
    if (!isset($prioritizedTags[$tag->priority])) {
      $prioritizedTags[$tag->priority] = $tag->tag;
    } else {
      for ($priorityCheck = $tag->priority - 1; $priorityCheck == 0; $priorityCheck--) {
        if (!isset($prioritizedTags[$priorityCheck])) {
          $prioritizedTags[$priorityCheck] = $tag->tag;
          break;
        }
      }
    }
  } 
  // Add a placeholder value
  array_push($prioritizedTags, 'PLACEHOLDER');
  // Sort the now prioritized tags by index descending, then re-index
  krsort($prioritizedTags);
  $prioritizedTags = array_values($prioritizedTags);
  // Remove the placeholder value, now the array begins at index 1 for DB submission
  unset($prioritizedTags[0]);
  return $prioritizedTags;
}
?>
