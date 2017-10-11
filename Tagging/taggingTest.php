<?php
require('../objectConstruction.php');
require('../dbConnect.php');

$url = "https://engadget.com/amp/2017/10/09/ea-extends-star-wars-battlefront-ii-public-beta-until-wednesda";

$site = new SiteData($url, 2, $conn);

// Take in $this->pageContents from the original fetch

// Fetch author perscribed tags

// Get all displayed text (remove all tags *GET RID OF JAVASCRIPT*)

// Get tags from the page (using all text) --> take the 20 most frequent words that aren't connecting words

// Check that the word isn't an adjective (adjectives don't make for very good tags...)

// From the tags, select the most suitable (maximum 8)

// Check if the tag is in the database, if so, get the ID, otherwise, create a new tag and fetch the ID
    // If the tag is not sorted into a category and doesn't fit a category, add to unsorted
      // Every time a tag is added to unsorted, check if at least 4 tags exist to create a sort for the those tags
        // A newly created category should be a synonym or an approximate synonym for the tags


// Push a new association to the database between each tag ID and the Entry ID






// CREATE A SCRIPT TO UPDATE EACH OF THE CURRENT DATABASE ENTRIES
 ?>
