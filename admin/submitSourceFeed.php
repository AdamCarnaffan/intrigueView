<?php 
include('../dbConnect.php');
include('../objectConstruction.php');
session_start();

$user = $_SESSION['user'];
$name = $conn->real_escape_string($_POST['name']);
$url = $conn->real_escape_string($_POST['url']);

try {
  // Validate the source feed link (name is already validated by this point)
  if (simplexml_load_file($url)) {
    // Submit the info to the database as a new Source
    $newSource = "CALL newFeed('$name', '$user->id', '$url', 1, 0, @placeholder)";
    // Throw an exception if the submission fails
    if (!$conn->query($newSource)) {
      throw new Exception($conn->error);
    }
  } else {
    throw new Exception("Could not load a feed at this URL", 179256);
  }
} catch (Exception $e) {
  echo json_encode([
    'error' => [
        'msg' => $e->getMessage(),
        'code' => $e->getCode()
    ]
  ]);
}
 ?>
