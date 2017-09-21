<html>
<body>
  <?php 
  include ('dbConnect.php');
  
  $username = (isset($_POST['username'])) ? $_POST['username'] : null;
  $password = (isset($_POST['password'])) ? $_POST['password'] : null;
  $error = null;
  
  if (strlen($username) < 25 && strlen($username) > 2) {
    $usernameIsValid = true;
  } else {
    $error = "Your username is not of the correct length";
    $usernameIsValid = false;
  }
  
  if (strlen($password) > 4) {
    $passwordIsValid = true;
  } else {
    $error = "Your password is too short";
    echo $password;
    $passwordIsValid = false;
  }
  
  if ($usernameIsValid && $passwordIsValid) {
    $passwordHash = password_hash($password, PASSWORD_DEFAULT);
    $addUser = "INSERT INTO `users` (`username`,`password`) VALUES ('$username','$passwordHash')";
    if ($conn->query($addUser)) {
      echo "User Added Successfully";
    } else {
      echo $conn->error;
    }
  }
  
  if (isset($_POST['username']) || isset($_POST['password'])) {
      echo $error;
  }
  
  
   ?>
   
<form method="POST">
  <input type="text" name="username" placeholder="New Username" /></br>
  <input type="text" name="password" placeholder="New Password" /></br>
  <input type="submit" name="addUser" value="Create New User" />
</form>
</body>
</html>
