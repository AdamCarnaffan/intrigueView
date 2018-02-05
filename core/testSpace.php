<?php

echo getFileData("https://raw.githubusercontent.com/Thefaceofbo/intrigueView/master/core/index.php");

function getFileData($gitLink) {
  $curlConn = curl_init();
  curl_setopt($curlConn, CURLOPT_URL, $gitLink);
  curl_setopt($curlConn, CURLOPT_SSL_VERIFYPEER, false);
  curl_setopt($curlConn, CURLOPT_RETURNTRANSFER, 1);
  $data = curl_exec($curlConn);
  curl_close($curlConn);

  if ($data == "404 Error: Not Found") {
    return false;
  }

  return $data;
}

?>
