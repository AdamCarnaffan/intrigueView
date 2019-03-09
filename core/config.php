<?php 

class config {
  
  public $configDirectory;
  public $coreDirectory;
  public $rootDirectory;
  public $dbLink;
  public $dbUser;
  public $dbPass;
  public $dbName;
  public $trackingVersion;
  public $displayVersion;
  public $fileVersions = [];
  
  public function __construct() {
    $directorySlash = '/';
    // Build main directory
    $tempTotalDir = explode($directorySlash, __DIR__);
    if (count($tempTotalDir) == 1) {
      $directorySlash = '\\';
      $tempTotalDir = explode($directorySlash, __DIR__);
    }
    array_pop($tempTotalDir);
    // Build configured directories
    $this->rootDirectory = implode($directorySlash, $tempTotalDir) . $directorySlash;
    $this->configDirectory = implode($directorySlash, $tempTotalDir) . "{$directorySlash}custom{$directorySlash}";
    $this->coreDirectory = implode($directorySlash, $tempTotalDir) . "{$directorySlash}core{$directorySlash}";
    // Get configs in directory
    $this->fetchConfigs();
  }
  
  public function fetchConfigs() {
    // Fetch database info
    $databaseConfig = json_decode(file_get_contents($this->configDirectory . "dbConfig.json"))->database;
    $this->dbLink = $databaseConfig->host;
    $this->dbUser = $databaseConfig->username;
    $this->dbPass = $databaseConfig->password;
    $this->dbName = $databaseConfig->database;
    
    // Fetch Versioning info
    $versionInfo = json_decode(file_get_contents($this->configDirectory . "version.json", "w"))->version;
    $this->trackingVersion = $versionInfo->trackingVersion;
    $this->displayVersion = $versionInfo->displayVersion;
    foreach ($versionInfo->files as $name=>$version) {
      $this->fileVersions[] = new File_Version($name, $version);
    }
  }
  
}

class File_Version {
  
  public $name;
  public $version;
  
  public function __construct($name, $version) {
    $this->name = $name;
    $this->version = $version;
  }
  
}

$cfg = new Config();

define("ROOT_PATH", $cfg->coreDirectory);

?>
