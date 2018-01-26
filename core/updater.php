<?php

// The root of the hosted project
$gitRoot = 'https://raw.githubusercontent.com/Thefaceofbo/intrigueView/master/';

// Access the version file for the local machine
$versionFile = fopen("versions.txt", "w");
$versionData = fgets($versionFile);
$versionNumber = "Local Number"

// Check the version on the github master

// Get the version data
$gitVersion = "Newest Number";

// Stop the run if the version number is the current
if ($versionNumber == $gitVersion) {
  echo "The site is currently up to date";
  return;
}

$changedFiles = [];

$dbChanges = [];

foreach ($changedFiles as $name) {
  if (str_pos('db_install/', $name) !== false) {
    $dbChanges[] = $name;
  }
}

if (count($dbChanges) > 0) {
  // Backup the DB

  // Run scripts
  foreach ($dbChanges as $name) {
    if (explode("/", $name)[1] != "db_finals" && explode(".", $name)[1] == "sql") {
      $script = $fetchToTemp($name);
      if (!$conn->multi_query($script)) {

        throw new Exception("The following error occured while updating the database: '{$conn->error}'");
      }
    }
  }
}

$fetchToTemp = function ($fileName) use ($gitRoot) {
  
  return "Open File in fopen format";
}

function download($gitFilePath) {
  $curlConn = curl_init();
  curl_setopt($curlConn, CURLOPT_URL, $gitFilePath);
  curl_setopt($curlConn, CURLOPT_SSL_VERIFYPEER, false);
  curl_setopt($curlConn, CURLOPT_RETURNTRANSFER, 1);
  $data = curl_exec($curlConn);
  curl_close($curlConn);

  $fileName = explode("/master/", $gitFilePath)[1];

  if (count(explode("/", $fileName)) > 1) {
    $subFolders = explode("/", $fileName);
    array_pop($subFolders);
    $currentDir = "tempDir/";
    foreach ($subFolders as $dir) {
      mkdir("$currentDir/$dir");
      $currentDir .= "$dir/";
    }
  }

  $newFile = fopen("tempDir/$fileName", "w");

  fwrite($newFile, $data);
  fclose($newFile);

}

// rename to move file
// mkdir to create temp directory
// fopen('new file', 'w') for creating a file

/*

UPDATE PROCEDURE

1) Create tempDir file for updated files
2) Download all changed files
3) Check for DB scripts
4) If DB scripts exist, backup DB and run them
5) If DB scripts fails, stop and restore old db
6) Copy old file versions to additional temp directory
7) Create any required directories for new files
8) Move all files
9) Check for exceptions in files
10) If exceptions are found, revert to old version and return failed update message



*/

?>
