<html>
<?php
require_once('../manageUser.php');
if (!$user->isAdmin) {
  header('location: ../index.php');
}
?>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
  <meta name="description" content="">
  <meta name="author" content="Adam Carnaffan">
  <link rel="icon" href="assets/icon.png">

  <title>Intrigue View <?php echo $cfg->displayVersion ?></title>

  <!-- Bootstrap core CSS -->
  <link href="../styling/bootstrap.min.css" rel="stylesheet">
  <link href="../styling/bootstrap-grid.css" rel="stylesheet">
  <!-- Custom styles -->
  <link href="../styling/custom-styles.css" rel="stylesheet">
  <!-- JavaScript -->
  <script src='../js/jquery-3.2.1.min.js'></script>
  <script src='administration.js'></script>
  <script src='../js/loginManager.js'></script>
</head>
<body class="hide-overflow">

  <nav class="navbar navbar-expand-md navbar-dark bg-dark mb-4">
    <a class="navbar-brand" href="../index.php">IntrigueView</a>
    <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarCollapse" aria-controls="navbarCollapse" aria-expanded="false" aria-label="Toggle navigation">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="navbarCollapse">
      <ul class="navbar-nav mr-auto">
        <li class="nav-item active">
          <a class="nav-link" href="../index.php">Home <span class="sr-only">(current)</span></a>
        </li>
      </ul>
      <ul class="navbar-nav">
        <button class="btn btn-outline-success-blue my-2 my-sm-0" onclick="logout()">Logout</button>
      </ul>
    </div>
  </nav>
      
  <div id="sidebar"  class="fix-sidebar">
      <!-- sidebar menu start-->
      <ul class="sidebar-menu">
          <li class="active">
              <a class="" href="splash.php">
                  <span>Dashboard</span>
              </a>
          </li>
          <li class="active">
              <a class="" href="feeds.php">
                  <span>Feeds</span>
              </a>
          </li>
          <li class="active">
              <a class="" href="entries.php">
                  <span>Entries</span>
              </a>
          </li>
          <?php
            foreach ($user->permissions as $perm) {
              if ($perm->permissionID == 1) {
                echo '<li class="active">
                    <a class="" href="users.php">
                        <span>Users</span>
                    </a>
                </li>';
                break;
              }
            }
          ?>
      </ul>
      <!-- sidebar menu end-->
  </div>
  <div class='container'>
    <h5>Change Admin Status:</h5>
    <?php 
    $getUsers = "SELECT users.userID, users.username, users.active FROM users 
                  JOIN user_permissions AS perms ON users.userID = perms.userID
                  GROUP BY users.userID
                  HAVING SUM(CASE WHEN perms.permissionID = 8 THEN 1 ELSE 0 END) = 0 
                  AND users.active = 1";
    $result = $conn->query($getUsers);
    echo "<table>";
    while ($row = $result->fetch_array()) {
      echo "<tr><td>" . $row[1] . "</td><td><button onclick='setAdmin(" . $row[0] . ")'>Set Admin</button></td></tr>";
    }
    echo "</table>";
     ?>
   </select>
   </br>
   <div id='entriesDisplay'>
   </div>
  </div>
  
</body>
</html>
