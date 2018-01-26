<?php
	// Encode the page
	header("Content-Type: application/xml;charset=UTF-8");
	require('dbConnect.php');
	// Set Default Values
	$feedSize = (isset($_GET['size'])) ? $_GET['size'] : "*";
	$feedIDs = (isset($_GET['selection'])) ? explode('+',$_GET['selection']) : 0;
	// Validate the Feed Size and ID Values
	$feedIDs = (is_numeric($feedIDs[0])) ? $feedIDs : 0;
	$feedSize = (is_numeric($feedSize)) ? $feedSize : '*';
	// Fetch subscribed feeds from the database
	$initalFeedSelection = implode(',',$feedIDs);
	// Query and fetch connected Feeds
	$getFeedIDs = "SELECT sourceFeed FROM feed_connections WHERE internalFeed IN('$initalFeedSelection')";
	$feedIDData = $conn->query($getFeedIDs);
	while ($feedID = $feedIDData->fetch_array()[0]) {
		array_push($feedIDs, $feedID);
	}
	// verify that no feed now exists twice
	array_unique($feedIDs);
	// Build the selection string
	$feedIDSelection = implode("','",$feedIDs);
	// Build the correct Query for the Database
	$getFeed = "SELECT title, url, datePublished, featureImage FROM entries 
								JOIN entry_connections AS connections ON entries.entryID = connections.entryID 
								WHERE visible = 1";
	if ($feedIDs[0] == 0) {
		$getFeed .= " ORDER BY datePublished DESC";
	} else {
		$getFeed .= " AND connections.feedID IN('$feedIDSelection') ORDER BY datePublished DESC";
	}
	if ($feedSize != "*") {
		$getFeed .= " LIMIT $feedSize";
	}
	// Get the Feed Name from the database
	if ($feedIDs[0] != 0) {
		$feedNames = [];
		if ($feedTitle = $conn->query("SELECT referenceTitle FROM feeds WHERE sourceID IN('$feedIDSelection')")) {
			while ($newTitle = $feedTitle->fetch_array()[0]) {
				array_push($feedNames, $newTitle);
			}
			$feedNamesString = implode(' &amp; ', $feedNames);
		} else {
			echo "<xml>An error occured fetching the feed(s).";
			exit;
		}
	} else {
		$feedNamesString = "All Feeds";
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
			<guid>" . $row[1] . "</guid>";
			if ($row[3] != null) {
				echo "<image>" . $row[3] . "</image>";
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
?>
