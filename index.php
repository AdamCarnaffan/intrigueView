<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
  <meta name="description" content="">
  <meta name="author" content="Adam Carnaffan">
  <link rel="icon" href="https://getpocket.com/a/i/pocketlogo.svg">

  <title>Intrigue View Beta 0.6</title>

  <!-- Bootstrap core CSS -->
  <link href="styling/bootstrap.min.css" rel="stylesheet">
  <link href="styling/bootstrap-grid.css" rel="stylesheet">
  <!-- Custom styles -->
  <link href="styling/custom-styles.css" rel="stylesheet">
  <script src='jquery-3.2.1.min.js'></script>
  <script src="displayManager.js"></script>
</head>
<body class="hide-overflow" onresize='resizeCanvas'>
  <!-- Fixed navbar -->
<nav class="navbar navbar-expand-md navbar-dark bg-dark mb-4">
  <a class="navbar-brand" href="index.php">IntrigueView</a>
  <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarCollapse" aria-controls="navbarCollapse" aria-expanded="false" aria-label="Toggle navigation">
    <span class="navbar-toggler-icon"></span>
  </button>
  <div class="collapse navbar-collapse" id="navbarCollapse">
    <ul class="navbar-nav mr-auto">
      <li class="nav-item active">
        <a class="nav-link" href="index.php">Home <span class="sr-only">(current)</span></a>
      </li>
      <!-- USED TO BROWSE FEEDS
      <li class="nav-item active">
        <a class="nav-link" href="#">Browse <span class="sr-only">(current)</span></a>
      </li>
    -->
      <li class="nav-item active fix-li">
        <input class="feed-source-input nav-input nav-link btn" id='search-input' type="text" placeholder="Article Search">
      </li>
      <li class='nav-item active'>
        <button class='feed-source-input nav-input nav-link btn btn-outline-success-blue inline-button' id='search-button' onclick='beginSearch()'>Go</button><!-- ADD ICON -->
      </li>
    </ul>
    <ul class="navbar-nav">
      <?php
        require('objectConstruction.php');
        session_start();
        $user = (isset($_SESSION['user'])) ? $_SESSION['user'] : null;
        // Change the User display based on a logged in user
        if (isset($user)) {
          echo '<a class="nav-item active nav-link hover-highlight" href="login.php">Welcome back, ' . $user->name . '</a>';
        } else {
          echo '<button class="btn btn-outline-success-blue my-2 my-sm-0" onclick="location.href=\'login.php\';">Login</button>';
        }
       ?>
    </ul>
  </div>
</nav>

<!-- Left Side Sort Bar -->
<!--<div class="sidebar-hide col-4 col-md-3 fix-sidebar round-bars search-border" id="sidebar">
  <div class="list-group round-bars">
    <h4>Search</h4>
    <input class="feed-source-input" id='search-input' type="text" placeholder="Search">
  </br> -->
  <!-- CATEGORY SELECTION GOES HERE --><!--
    <button class="btn btn-outline-success-blue" onclick="beginSearch()" href="#">Search</button>
  </div>
</div> -->

<!-- Main album view -->
<div class="container" id='feed-content'>
  <div class="col-12 col-md-12">
    <div class="row" id="feed-view">
    <!-- PLACEHOLDER -> SMALL CIRCLE TO CALL THE SORT ORDERS ON MOBILE-->
    </div><!--/row-->
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
var ReturnButton = "<div class='button-holder' id='return-button'><a href='#' onclick='returnToTop()'><img class='return-button' src='assets/returnToTop.png'></a></div>";
var loadingCanvas = "<div id='loading'><canvas id='loading-dots' width='900' height='600'>Loading...</canvas></div>";
// Instantiate necessary global variables
var returnButtonIsDisplayed = false;
var cooldown = 0.8;
var entriesDisplayed = 0;
var search = "";
var display = true;
// Make initial display
queryEntries(51);

$(document).ready( function () {
  // Reset scroll before watching for scroll changes
  $(this).scrollTop(0);
  // Begin waiting for the scroll
  $(window).scroll(function() {
    // Load more entries
    if (($(document).scrollTop() / ($(document).height() - $(window).height())) > cooldown && entriesDisplayed < 150 && display == true) {
      queryEntries(26, true);
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

<!--
<div class="container">
  <div class="jumbotron">
    <h1>Navbar example</h1>
    <p class="lead">This example is a quick exercise to illustrate how the top-aligned navbar works. As you scroll, this navbar remains in its original position and moves with the rest of the page.</p>
  </div>
</div>

<div class="col-6 col-lg-3 tile-wrapper">
  <div class="feed-tile">
    <a href="http://google.ca" class="hover-detect"><span class="entry-url"></span></a>
    <h4 class="entry-heading">Article Heading</h4>
    <div class="image"><img src="https://hbr.org/resources/images/article_assets/2017/09/sept17-14-668999778.jpg"/></div>
    <div class="entry-stats">
      <p class="site-info">
        <img src="http://jsfiddle.net/favicon.png" class="site-icon"/>
        <a class="site-info-url" href="https://getpocket.com/a/queue/">google.ca</a>
      </p>
    </div>
  </div>
</div>

<form class="form-inline mt-2 mt-md-0">
  <input class="form-control mr-sm-2" type="text" placeholder="Search" aria-label="Search">
  <button class="btn btn-outline-success my-2 my-sm-0" type="submit">Search</button>
</form>
-->
