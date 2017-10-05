<?php 
	header("Content-Type: application/xml; charset=ISO-8859-1");
	include('dbconnect.php');
	// Set Default Values
	$feedSize = (isset($_GET['size'])) ? $_GET['size'] : 100;
	$feedId = (isset($_GET['selection'])) ? $_GET['selection'] : 0;
	// Build the correct Query for the Database
	if ($feedId == 0) {
		if ($feedSize == "*") {
			$getFeed = "SELECT title, url, date_published FROM entries ORDER BY date_published DESC";
		} else {
			$getFeed = "SELECT title, url, date_published FROM entries ORDER BY date_published DESC LIMIT $feedSize";
		}
	} else {
		if ($feedSize == "*") {
			$getFeed = "SELECT title, url, date_published FROM entries WHERE feed_id = '$feedId' ORDER BY date_published DESC";
		} else {
			$getFeed = "SELECT title, url, date_published FROM entries WHERE feed_id = '$feedId' ORDER BY date_published DESC LIMIT $feedSize";
		}
	}
	// Generate Feed details
	echo '<?xml version="1.0" encoding="UTF-8"?><rss version="2.0">';
	if ($feedId != 0) {
		$feedTitle = $conn->query("SELECT title FROM feeds WHERE feed_id = '$feedId'")->fetch_array()[0];
	} else {
		$feedTitle = "All Feeds";
	}
	// Generate Entry objects
	if ($result = $conn->query($getFeed)) {
		echo "<channel>
		
		<title>My Intrigue Feed: " . $feedTitle . "</title>
		<description>Feed courtesy of IntrigueView</description>
		<link>http://intrigueView.3rdglance.com/feed.php</link>
		
		
		"; 
		while ($row = $result->fetch_array()) {
			$row[0] = str_replace("&nbsp;", " ", $row[0]);
			echo "
			<entry>
			<title>" . $row[0] . "</title>
			<link>" . $row[1] . "</link>
			<guid>" . $row[1] . "</guid>
			<pubDate>" . $row[2] . "</pubDate>
			</entry>";
		}
		echo "
		</channel>
		
		</rss>";
	} else {
		throw new Exception("Failed to get the Feed from the database..." . $conn->error);
	}
?>
