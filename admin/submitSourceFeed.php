<?php 
include('../dbConnect.php');
include('../objectConstruction.php');
session_start();

$user = $_SESSION['user'];
$name = $conn->real_escape_string($_POST['name']);
$url = $conn->real_escape_string($_POST['url']);
$image = $conn->real_escape_string($_POST['image']);
$description = $conn->real_escape_string($_POST['desc']);

try {
  // Validate the source feed link (name is already validated by this point)
  if (simplexml_load_file($url)) {
    // Submit the info to the database as a new Source
    $newSource = "CALL newFeed('$name', '$user->id', '$url', '$image', '$description', 1, 0, @newFeedIDReturn);
                  SELECT @newFeedIDReturn;";
    // Throw an exception if the submission fails
    if ($conn->multi_query($newSource)) {
      // http://rss.nytimes.com/services/xml/rss/nyt/Business.xml?cachebusterTimestamp=1511646742314
      $conn->next_result();
      $idSet = $conn->store_result();
      $id = $idSet->fetch_array()[0];
    } else {
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
echo json_encode(['id' => $id]);
 ?>
