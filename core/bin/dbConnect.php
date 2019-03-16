<?php 

if (!isset($cfg)) {
  require_once('../config.php');
}

// Database connection string
$conn = new mysqli($cfg->dbLink,$cfg->dbUser,$cfg->dbPass,$cfg->dbName);

?>
