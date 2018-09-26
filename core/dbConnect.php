<?php 

if (!isset($cfg)) {
  require_once('buildConfig.php');
}

require_once('class/class_std.php');

// Database connection string
$conn = new mysqli($cfg->dbLink,$cfg->dbUser,$cfg->dbPass,$cfg->dbName);

?>
