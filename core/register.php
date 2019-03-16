<?php
// Check if a user is already logged in
require_once('config.php');
require_once(ROOT_PATH . '/bin/manageUser.php');

if (!$user->isTemp) {
   header('location: index.php');
}
/*
WANTS
-----
Press enter to submit
Dynamic username fetches (after switching fields)
Submit user with new procedure (Check-out sendRegistration.php)
Shift validations from PHP to js
Send data from proc to User class (Class may need some work xd) (class/class_userData.php)
Fix logo on pages that don't use mine :L
*/
?>
<head>
   <meta charset="utf-8">
   <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
   <meta name="description" content="">
   <meta name="author" content="Adam Carnaffan">
   <link rel="icon" href="https://getpocket.com/a/i/pocketlogo.svg">

   <title>Intrigue View <?php echo $cfg->displayVersion ?></title>

   <!-- Bootstrap core CSS -->
   <link href="styling/bootstrap.min.css" rel="stylesheet">
   <link href="styling/bootstrap-grid.css" rel="stylesheet">
   <!-- Custom styles -->
   <link href="styling/custom-styles.css" rel="stylesheet">
   <!-- JavaScript -->
   <script src='js/jquery-3.2.1.min.js'></script>
   <script src='js/popper.js'></script>
   <script src='js/bootstrap.js'></script>
   <script src='js/loginManager.js'></script>
</head>
<body class="hide-overflow dark-back">
   <!-- Fixed navbar -->
   <nav class="navbar navbar-expand-md navbar-dark bg-dark dropdown-ontop">
     <a class="icon-brand icon-sprite-white" href="index.php"></a>
     <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarCollapse" aria-controls="navbarCollapse" aria-expanded="false" aria-label="Toggle navigation">
       <span class="navbar-toggler-icon"></span>
     </button>
     <div class="collapse navbar-collapse" id="navbarCollapse">
       <ul class="navbar-nav mr-auto nav-navigation fix-ul">
         <!-- <li class="nav-item active nav-hoverable">
           <a class="nav-link nav-underline" title="See the Most Popular Articles From the Last Few Days" href="index.php">Featured<span class="sr-only">(current)</span></a>
         </li>
         <li class="nav-item active nav-hoverable">
           <a class="nav-link nav-underline" title="Scroll Through a Continuous Feed of Recommended Articles" href="recommended.php">Recommended<span class="sr-only">(current)</span></a>
         </li>
         <li class="nav-item active nav-hoverable">
           <a class="nav-link nav-underline" title="Browse a Compilation of All Public Feeds" href="browse.php">Browse<span class="sr-only">(current)</span></a>
         </li> -->
         <?php
         if (!$user->isTemp) {
            echo '<li class="nav-item active nav-hoverable">
              <a class="nav-link nav-underline" title="See Your Saved Tiles" href="saved.php">Saved<span class="sr-only">(current)</span></a>
            </li>';
         }
         ?>
         <!-- <li class="nav-item active">
           <a class="nav-link nav-underline nav-activate" href="#" title="Export the Current Feed as RSS" onclick="return openInNewTab('feed.php?size=10&selection=' + feedSelection.join('+'))">Export RSS<span class="sr-only">(current)</span></a>
         </li> -->
       </ul>
       <ul class="navbar-nav mr-auto fix-ul">
       </ul>
       <ul class="navbar-nav dropdown-ontop">
         <!-- <?php
           // Change the User display based on a logged in user
           if (!$user->isTemp) {
             echo "<div class='dropdown'>";
             echo '<a class="nav-item active nav-link nav-underline hover-highlight dropdown-toggle" href="#" data-toggle="dropdown">Welcome back, ' . $user->name . '</a>';
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
          ?> -->
       </ul>
     </div>
   </nav>

 <!-- Login Box (same as main album view)-->
  <div class="container login-top-pad remove-scrolling">
    <div class="col-12 col-md-10 login-centered">
      <div class="row" id="feed-view">
        <div class="col-12 col-lg-6 tile-wrapper login-center">
          <div class="feed-tile login-adjust">
            <h3 class="entry-heading heading-pad">Registration</h3>
            <input class="form-control mr-sm-2 text-box-input input-length" id="username-input" type="text" placeholder="Username" aria-label="Username">
            <p class="user-error-message" id="username-error"></p>
            <br>
            <input class="form-control mr-sm-2 text-box-input input-length" id="password-input" type="password" placeholder="Password" aria-label="Password">
            <p class="user-error-message" id="password-error"></p>
            <br>
            <input class="form-control mr-sm-2 text-box-input input-length" id="password-confirm" type="password" placeholder="Confirm Password" aria-label="Confirm Password">
            <p class="user-error-message" id="confirm-password-error"></p>
            <br>
            <input class="form-control mr-sm-2 text-box-input input-length" id="email-input" type="text" placeholder="Email" aria-label="Email">
            <p class="user-error-message" id="email-error"></p>
            <input class="btn btn-outline-success-blue my-2 my-sm-0 text-box-input" type="button" onclick='validateRegister()' value="Register">
          </div>
        </div><!--/span-->
      </div>
    </div><!--/row-->
  </div><!--/span-->
 </div>


</body>
</html>
