<?php 
$fullDomain = $_SERVER['HTTP_HOST'];
if (count(explode(".",$fullDomain)) > 1) {
  $domainGet = explode(".",$fullDomain);
  array_shift($domainGet);
  $domain = "." . implode(".",$domainGet);
  ini_set('session.cookie_domain', $domain);
}
session_start();
 ?>
