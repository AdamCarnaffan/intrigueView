<?php
session_start();
if (!isset($_SESSION['user'])) {
  header('location: ../login.html');
}
session_abort();
 ?>
