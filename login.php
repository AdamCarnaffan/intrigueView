<?php
  // Check if a user is already logged in
  require('fixSession.php');
  if (isset($_SESSION['user'])) {
      header('location: admin/index.php');
  }
?>
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
  <!-- JavaScript -->
  <script src='js/jquery-3.2.1.min.js'></script>
  <script src='js/bootstrap.js'></script>
</head>
<body class="hide-overflow">
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
    </ul>
    <ul class="navbar-nav">
      <button class="btn btn-outline-success-blue my-2 my-sm-0 separate" onclick="location.href='register.php';">Register</button>
      <button class="btn btn-outline-success-blue my-2 my-sm-0" onclick="location.href='login.php';">Login</button>
    </ul>
  </div>
</nav>

<!-- Login Box (same as main album view)-->
  <div class="container login-top-pad">
    <div class="col-12 col-md-10 login-centered">
      <div class="row" id="feed-view">
        <div class="col-12 col-lg-6 tile-wrapper login-center">
          <div class="feed-tile login-adjust">
            <h3 class="entry-heading heading-pad">Feed Management Login</h3>
            <form method="post" class="mt-2 mt-md-0">
              <input class="form-control mr-sm-2 text-box-input input-length" id="username-input" type="text" placeholder="Username" aria-label="Username">
            </br>
              <input class="form-control mr-sm-2 text-box-input input-length" id="password-input" type="password" placeholder="Password" aria-label="Password">
              <p class="user-error-message" id="login-error"></p>
              <input class="btn btn-outline-success my-2 my-sm-0 text-box-input" type="button" onclick='validateLogin()' value="Login">
            </form>
          </div>
        </div><!--/span-->
      </div>
    </div><!--/row-->
  </div><!--/span-->
</div>


</body>
<!-- Scripting -->
<script src="js/loginManager.js"></script>
</html>

<!--
<div class="container">
  <div class="jumbotron">
    <h1>Navbar example</h1>
    <p class="lead">This example is a quick exercise to illustrate how the top-aligned navbar works. As you scroll, this navbar remains in its original position and moves with the rest of the page.</p>
  </div>
</div>
