<?php
$selectionLimit = 10;
$selectionOffset = 5;

$getEntries = "SELECT entries.title, entries.url, entries.datePublished, entries.featureImage, site.url, site.icon FROM entries
	               JOIN sites ON entries.siteID = sites.siteID
                 WHERE entries.visible = 1
                 ORDER BY entries.datePublished DESC, entries.entryID ASC
                 LIMIT $selectionLimit OFFSET $selectionOffset";
// Adjust the query if a search is present
$search = false;
$searchKey = "lol";

if ($searchKey != null && strlen($searchKey) > 0) {
  $getEntries = substr_replace($getEntries, " AND entries.title LIKE '%$searchKey%'", 230 ,1);
  $search = true;
}


echo $getEntries;
echo "lolzs";
?>
