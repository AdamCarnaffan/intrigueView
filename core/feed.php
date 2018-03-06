<?php
	// Encode the page
	header("Content-Type: application/xml;charset=UTF-8");
	require('dbConnect.php');
	// Set Default Values
	$feedSize = (isset($_GET['size'])) ? $_GET['size'] : "*";
	$feedIDs = (isset($_GET['selection'])) ? explode(' ', $_GET['selection']) : [0];
	$tags = (isset($_GET['tags'])) ? explode(' ', $_GET['tags']) : [0];
	$tagMode = (isset($_GET['tagMode'])) ? $_GET['tagMode'] : "include";
	// Validate the Feed Size and ID Values
	$feedIDs = (is_numeric($feedIDs[0])) ? $feedIDs : [0];
	$feedSize = (is_numeric($feedSize)) ? $feedSize : '*';
	$tags = (is_numeric($tags[0])) ? $tags : [0];
	$tagMode = ($tagMode == "use") ? $tagMode : "include";
	// Fetch subscribed feeds from the database
	$initalFeedSelection = implode(',',$feedIDs);
	// Query and fetch connected Feeds
	$getFeedIDs = "SELECT sourceFeed FROM feed_connections WHERE internalFeed IN('$initalFeedSelection')";
	$feedIDData = $conn->query($getFeedIDs);
	while ($feedID = $feedIDData->fetch_array()[0]) {
		$feedIDs[] = $feedID;
	}
	// verify that no feed now exists twice
	array_unique($feedIDs);
	// Build the selection string
	$feedIDSelection = implode("','", $feedIDs);
	// Build the tag selection string
	$tagIDSelection = implode("','", $tags);
	// Build the correct Query for the Database
	$getFeed = "SELECT title, url, datePublished, featureImage FROM entries 
								JOIN entry_connections AS connections ON entries.entryID = connections.entryID
								JOIN entry_tags AS tagConn ON entries.entryID = tagConn.entryID 
								WHERE visible = 1";
	if ($feedIDs[0] != 0) {
		$getFeed .= " AND connections.feedID IN('$feedIDSelection')";
	}
	if ($tags[0] != 0) {
		$getFeed .= " AND tagConn.tagID IN('$tagIDSelection')";
	}
	// Add sorting
	$getFeed .= "GROUP BY entries.entryID ORDER BY datePublished DESC";
	// Add limiter
	if ($feedSize != "*") {
		$getFeed .= " LIMIT $feedSize";
	}
	// Get the Feed Name from the database
	if ($feedIDs[0] != 0) {
		$feedNames = [];
		if ($feedTitle = $conn->query("SELECT referenceTitle FROM feeds WHERE sourceID IN('$feedIDSelection')")) {
			while ($newTitle = $feedTitle->fetch_array()[0]) {
				$feedNames[] = $newTitle;
			}
			$feedNamesString = implode(' &amp; ', $feedNames);
		} else {
			echo "<xml>An error occured fetching the feed(s).";
			exit;
		}
	} else {
		$feedNamesString = "All Feeds";
	}
	// Append tag data to feed name
	if ($tags[0] != 0) {
		$tagNames = [];
		if ($tag = $conn->query("SELECT tagName FROM tags WHERE tagID IN('$tagIDSelection')")) {
			while ($tagTitle = $tag->fetch_array()) {
				$tagNames[] = capitalize($tagTitle[0]);
			}
			$tagNameString = implode(', ', $tagNames);
			$tagMode = ($tagMode == "use") ? "Using Tags " : "Including Tags";
			$feedNamesString .= " - $tagMode '$tagNameString'";
		} else {
			echo "<xml>An error occured fetching the feed(s).";
			exit;
		}
	}
	// Generate Feed details
	echo '<?xml version="1.0" encoding="UTF-8"?><rss version="2.0">';
	// Generate Entry objects
	if ($result = $conn->query($getFeed)) {
		echo "<channel>

		<title>My Intrigue Feed: " . $feedNamesString . "</title>
		<description>Feed courtesy of IntrigueView</description>
		<link>http://intrigueView.3rdglance.com/feed.php</link>


		";
		while ($row = $result->fetch_array()) {
			// Purge unsupported XML characters
			$row[0] = str_replace("&nbsp;", " ", $row[0]);
			$row[0] = str_replace("&ndash;", "-", $row[0]);
			// Convert all to & to sterilize 
			$row[3] = str_replace("&amp;", "&", $row[3]);
			$row[3] = str_replace("&", "&amp;", $row[3]);
			echo "
		<item>
			<title>" . $row[0] . "</title>
			<link>" . $row[1] . "</link>
			<guid>" . $row[1] . "</guid>
			";
			if ($row[3] != null) {
				echo "<image>" . $row[3] . "</image>
			";
			}
			echo "<pubDate>" . $row[2] . "</pubDate>
		</item>";
		}
		echo "
	</channel>

</rss>";
	} else {
		throw new Exception("Failed to get the Feed from the database..." . $conn->error);
	}
	
	function capitalize($value) {
		$split = str_split($value);
		$split[0] = strtoupper($split[0]);
		return implode($split);
	}
?>
