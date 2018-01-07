<?php
  require('fixSession.php');
  session_unset('user');
  require('manageUser.php');
 ?>
