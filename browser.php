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
  <!-- Javascript -->
  <script src='js/jquery-3.2.1.min.js'></script>
  <script src='js/displayManager.js'></script>
  <script src='js/loginManager.js'></script>
  <script src='js/popper.js'></script>
  <script src='js/bootstrap.js'></script>
</head>
<body class="hide-overflow" onresize='resizeCanvas'>
  <!-- Fixed navbar -->
<nav class="navbar navbar-expand-md navbar-dark bg-dark mb-4">
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
        <a class="nav-link" title="Browse a Compilation of All Public Feeds" href="browser.php">Browse<span class="sr-only">(current)</span></a>
      </li>
      <?php 
      if (isset($user)) {
        echo '<li class="nav-item active">
          <a class="nav-link" title="See Your Personalized Feed Selection" href="myFeeds.php">My Feeds<span class="sr-only">(current)</span></a>
        </li>';
      }
      ?>
      <li class="nav-item active">
        <a class="nav-link" href="#" title="Export the Current Feed as RSS" onclick="return openInNewTab('feed.php?size=10&selection=0')">Export RSS<span class="sr-only">(current)</span></a>
      </li>
    </ul>
    <ul class="navbar-nav mr-auto fix-ul">
      <li class="nav-item active fix-li">
        <input class="feed-source-input nav-input nav-link btn nav-search" id='search-input' type="text" placeholder="Feed Search">
      </li>
      <li class='nav-item active fix-li'>
        <button class='feed-source-input nav-input btn btn-outline-success-blue inline-button fix-nav-button' id='search-button' onclick='beginSearch()'>Go</button><!-- ADD ICON -->
      </li>
    </ul>
    <ul class="navbar-nav">
      <?php
        require('objectConstruction.php');
        include('fixSession.php');
        $user = (isset($_SESSION['user'])) ? $_SESSION['user'] : null;
        // Change the User display based on a logged in user
        if (isset($user)) {
          echo "<div class='dropdown'>";
          echo '<a class="nav-item active nav-link hover-highlight dropdown-toggle" href="#" data-toggle="dropdown">Welcome back, ' . $user->name . '</a>';
          echo '<ul class="dropdown-menu dropdown-menu-right dropdown-align">';
          echo '<li display="block"><a class="move-right dropdown-link" href="profile.php">My Profile</a></li>';
          echo '<li class="divider"></li>';
          echo '<li display="block"><a class="move-right dropdown-link" href="builder.php">Feed Builder</a></li>';
          echo '<li class="divider"></li>';
          echo '<li display="block"><a class="move-right dropdown-link" href="settings.php">Settings</a></li>';
          // Only display the administration area if the user has access
          foreach ($user->permissions as $perm) {
            if ($perm->permissionId == 8) {
              echo '<li class="divider"></li>';
              echo '<li display="block"><a class="move-right dropdown-link" href="admin/splash.php">Administration</a></li>';
              break;
            }
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
<!-- <div class="container shortened">
  <div class="searching">
    <h3 class="filter-coloring move-heading">Filter Results
      <button class='btn btn-outline-success-blue separate fix-button-margin reset-button' onclick='resetQueries()'>Reset Filters</button>
    </h3>
    <div>
      <h5 class="heading-inline filter-coloring vertical-centering">Search:</h5>
      <input class="feed-source-input nav-input btn nav-search" id='search-input' type="text" placeholder="Article Search">
      <button class='feed-source-input nav-input btn btn-outline-success-blue inline-button' id='search-button' onclick='beginSearch()'>Go</button>
    </div>
  </div>
    <div class="tagging">
    <h3 class="filter-coloring move-heading heading-inline">Tags
    <button id='and-tag' class='btn btn-outline-success-blue separate fix-button-margin' onclick='changeTagMode()'>AND</button>
    <button id='or-tag' class='btn btn-outline-success-blue separate fix-button-margin' onclick='changeTagMode()'>OR</button>
    </h3>
    <div class="filter-coloring" id="tag-collection">
    </div>
  </div>
</div> -->
<!-- ALL ARTICLES GO HERE -->
<div class="container" id='feed-content'>
  <div class="col-12 col-md-12">
    <div class="row" id="feed-view">
    </div><!--/row-->
  </div><!--/span-->
</div>

<!-- Bottom Bar -->
<div class="navbar-dark navbar bg-dark">
  <a class="fix-link-color nav-link" href="https://github.com/Thefaceofbo">By Adam Carnaffan<span class="sr-only">(current)</span></a>
</div>
</body>
</html>
