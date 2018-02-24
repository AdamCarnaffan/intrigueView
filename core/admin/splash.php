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

  <aside>
      <div id="sidebar"  class="nav-collapse ">
          <!-- sidebar menu start-->
          <ul class="sidebar-menu">
              <li class="active">
                  <a class="" href="index.php">
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
  </aside>
</body>
</html>
