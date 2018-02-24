<!DOCTYPE html>
<html lang="en">
<?php
require_once('manageUser.php');
require_once('buildConfig.php');
?>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
  <meta name="description" content="">
  <meta name="author" content="Adam Carnaffan">
  <link rel="icon" href="assets/icon.png">

  <title>Intrigue View <?php echo $cfg->displayVersion ?></title>

  <!-- Bootstrap core CSS -->
  <link href="styling/bootstrap.min.css" rel="stylesheet">
  <link href="styling/bootstrap-grid.css" rel="stylesheet">
  <!-- Iconography CSS -->
  <link href="https://maxcdn.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css" rel="stylesheet">
  <!-- Custom styles -->
  <link href="styling/custom-styles.css" rel="stylesheet">
  <!-- Javascript -->
  <script src='js/jquery-3.2.1.min.js'></script>
  <script src='js/jqueryUI.min.js'></script>
  <script src='js/displayManager.js'></script>
  <script src='js/loginManager.js'></script>
  <script src='js/popper.js'></script>
  <script src='js/bootstrap.js'></script>
</head>
<body class="hide-overflow" onresize='resizeCanvas'>
  <!-- Fixed navbar -->
<nav id='navigator' class="navbar navbar-expand-md navbar-dark bg-dark mb-4">
  <a class="navbar-brand" href="index.php">IntrigueView</a>
  <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarCollapse" aria-controls="navbarCollapse" aria-expanded="false" aria-label="Toggle navigation">
    <span class="navbar-toggler-icon"></span>
  </button>
  <div class="collapse navbar-collapse" id="navbarCollapse">
    <ul class="navbar-nav mr-auto nav-navigation fix-ul">
      <li class="nav-item active">
        <a class="nav-link" title="See the Most Popular Articles From the Last Few Days" href="index.php">Featured<span class="sr-only">(current)</span></a>
      </li>
      <li class="nav-item active">
        <a class="nav-link" title="Browse a Compilation of All Public Feeds" href="browse.php">Browse<span class="sr-only">(current)</span></a>
      </li>
      <?php
      if (!$user->isTemp) {
        echo '<li class="nav-item active">
          <a class="nav-link" title="See Your Personalized Feed Selection" href="myFeeds.php">My Feeds<span class="sr-only">(current)</span></a>
        </li>';
      }
      ?>
      <li class="nav-item active">
        <a class="nav-link" href="#" title="Export the Current Feed as RSS" onclick="return openInNewTab('feed.php?size=10&selection=' + feedSelection.join('+'))">Export RSS<span class="sr-only">(current)</span></a>
      </li>
    </ul>
    <ul class="navbar-nav mr-auto fix-ul">
      <!-- <li class="nav-item active fix-li">
        <input class="feed-source-input nav-input nav-link btn nav-search" id='search-input' type="text" placeholder="Article Search">
      </li>
      <li class='nav-item active fix-li'>
        <button class='feed-source-input nav-input nav-link btn btn-outline-success-blue inline-button fix-mobile' id='search-button' onclick='beginSearch()'>Go</button><!-- ADD ICON -->
      <!--</li>-->
    </ul>
    <ul class="navbar-nav">
      <?php
        // Change the User display based on a logged in user
        if (!$user->isTemp) {
          echo "<div class='dropdown'>";
          echo '<a class="nav-item active nav-link hover-highlight dropdown-toggle" href="#" data-toggle="dropdown">Welcome back, ' . $user->name . '</a>';
          echo '<ul class="dropdown-menu dropdown-menu-right dropdown-align">';
          echo '<li display="block"><a class="move-right dropdown-link" href="profile.php">My Profile</a></li>';
          echo '<li class="divider"></li>';
          echo '<li display="block"><a class="move-right dropdown-link" href="builder.php">Feed Builder</a></li>';
          echo '<li class="divider"></li>';
          echo '<li display="block"><a class="move-right dropdown-link" href="settings.php">Settings</a></li>';
          if ($user->isAdmin) {
            echo '<li class="divider"></li>';
            echo '<li display="block"><a class="move-right dropdown-link" href="admin/splash.php">Administration</a></li>';
          }
          echo '<li class="divider"></li>';
          echo '<li display="block"><a class="move-right dropdown-link" href="#" onclick="return logout()">Logout</a></li>';
          echo "</ul>";
          echo "</div>";
        } else {
          echo '<button class="btn btn-outline-success-blue my-2 my-sm-0 separate" onclick="location.href=\'register.php\';">Register</button>';
          echo '<button class="btn btn-outline-success-blue my-2 my-sm-0" onclick="location.href=\'login.php\';">Login</button>';
        }
       ?>
    </ul>
  </div>
</nav>

<!-- Main album view -->
<!-- ALL ARTICLES GO HERE -->
<div class="container no-top-offset" id='feed-content'>
  <div class="col-md-12" id="content-display">
    <div class="row" id="feed-view">
      <!-- FEEDS POPULATE HERE FIRST -->
    </div>
  </div><!--/span-->
</div>

<!-- Bottom Bar -->
<div class="navbar-dark navbar bg-dark">
  <a class="fix-link-color nav-link" href="https://github.com/Thefaceofbo">By Adam Carnaffan<span class="sr-only">(current)</span></a>
</div>
</body>
<!-- Scripting -->
<script>
// Define Variable display buttons
var ReturnButton = "<div class='button-holder' id='return-button'><a class='return-button front' href='#' onclick='returnToTop()'><img class='return-button front' src='assets/returnToTop.png'></a></div>";
var loadingCanvas = "<div id='loading'><canvas id='loading-dots' width='900' height='600'>Loading...</canvas></div>";
var taggingDisplay = "\n<div id='filter-display' class='container shortened'>\n<div class='searching'>\n<h3 class='filter-coloring move-heading'>Filter Results\n<button class='btn btn-outline-success-blue separate fix-button-margin reset-button' onclick='resetQueries()'>Reset Filters</button></h3>\n<div class='search-field'><h5 class='heading-inline filter-coloring vertical-centering'>Search:</h5>\n<input class='feed-source-input nav-input btn nav-search' id='search-input' type='text' placeholder='Article Search'>\n<button class='feed-source-input nav-input btn btn-outline-success-blue inline-button' id='search-button' onclick='beginSearch()'>Go</button></div></div><div class='tagging'><h3 class='filter-coloring move-heading heading-inline'>Tags\n<button id='and-tag' class='btn btn-outline-success-blue separate fix-button-margin' onclick='changeTagMode()'>AND</button>\n<button id='or-tag' class='btn btn-outline-success-blue separate fix-button-margin' onclick='changeTagMode()'>OR</button></h3><!-- TAGS POPULATED HERE --><div class='filter-coloring' id='tag-collection'></div></div></div>";
var browseButtons = "<div id='browse-nav'>\n<div id='browse-back' class='nav-button'><a href='#' onclick='return showBrowsePanel()'><span class='entry-url'></span></a>\n< Back\n</div><div id='save-feed-button' class='nav-button second-absolute-button'><a href='#' onclick='return saveFeed(this, feedSelection[0], false)'><span class='entry-url'></span></a>Save Feed</div></div>";
// Instantiate necessary global variables
var returnButtonIsDisplayed = false;
var cooldown = 0.8;
var entriesDisplayed = 0;
var search = "";
var leftMarginSpace = 0;
var viewingFeed = false;
var queryTags = [];
var display = true;
var feedSelection = [];
var currentTagMode = 1; // Defined in a global scope to use in multiple functions

// Check for local feedselection storage
if (feedSelection.length == 0) {
  try {
    if (sessionStorage.getItem("selectedFeeds") != "" && sessionStorage.getItem("selectedFeeds") != null) {
      feedSelection.push(sessionStorage.getItem("selectedFeeds"));
    }
  } catch (err) {
    console.log(err);
  }
}

if (feedSelection.length < 1) {
  $('#feed-view').html("<h3 class='feed-tile-align'>Browse Feeds to Find Content of Interest</h3>");
  queryFeeds();
} else {
  selectFeed(null, feedSelection);
}

$(document).ready( function () {
  // Reset scroll before watching for scroll changes
  $(this).scrollTop(0);
  // Begin waiting for the scroll
  $(window).scroll(function() {
    // Load more entries
    if (($(document).scrollTop() / ($(document).height() - $(window).height())) > scrollCooldown && entriesDisplayed < 500 && display == true && viewingFeed) {
      queryEntries(26, feedSelection, true);
    }
    // Display Settings for the Return to Top button
    if ($(document).scrollTop() > 600 && returnButtonIsDisplayed == false) {
      returnButtonIsDisplayed = true;
      $(document.body).append(ReturnButton);
    } else if ($(document).scrollTop() < 200) {
      $('#return-button').remove();
      returnButtonIsDisplayed = false;
    }
  });
});
// Allow the Search to begin on enter keypress
$('#search-input').keypress(function(event) {
  if (event.keyCode == 13) {
    beginSearch();
  }
});

</script>
</html>
