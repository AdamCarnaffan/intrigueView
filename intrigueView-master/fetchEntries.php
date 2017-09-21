<?php 
include ('dbConnect.php');

$selectionLimit = 24;
$getEntries = "SELECT feed.title, entries.title, entries.url, entries.date_published, entries.feature_image, entries.preview_text, site.url, site.icon FROM `entries` JOIN `feeds` AS feed ON entries.feed_id = feed.feed_id JOIN `sites` AS site ON entries.site_id = site.site_id ORDER BY `date_published` DESC LIMIT $selectionLimit";
$result = $conn->query($getEntries);
while ($row = $result->fetch_array()) {
  echo $row[1];
}

/* TEST RESULT
echo '<div class="col-6 col-lg-3 tile-wrapper">
  <div class="feed-tile">
    <!-- LINK TO ARTICLE HERE -->
    <a href="http://google.ca" class="hover-detect"><span class="entry-url"></span></a>
    <h5 class="entry-heading">Article Heading which is longer than before, therefore hopefully shrinking image</h5>
    <div class="image-container"><img class="image" src="https://d33ypg4xwx0n86.cloudfront.net/direct?url=https%3A%2F%2Fassets.fastcompany.com%2Fimage%2Fupload%2Fw_707%2Cf_auto%2Cq_auto%3Abest%2Cfl_lossy%2Fwp-cms%2Fuploads%2F2017%2F09%2Fp-1-what-do-you-think-of-the-iphone-x-alan-key.jpg&resize=w704"/></div>
    <div class="entry-stats">
      <p class="site-info">
        <img src="http://jsfiddle.net/favicon.png" class="site-icon"/><!-- SITE ICON -->
        <a class="site-info-url" href="https://getpocket.com/a/queue/">google.ca</a>
      </p>
    </div>
  </div><!--/span-->
</div>';


*/

 ?>
