// Listen for enter keypress to submit to validation function
$(document).keypress(function(event) {
  if (event.keyCode == 13) {
    validateLogin();
  }
});

// apply a cooldown to prevent spam login attempts
var cooldown = 0;
setInterval(reduceCooldown, 1000);

function validateLogin() {
  // Set username and password equal to input
  var inputUsername = document.getElementById('username-input').value;
  var inputPassword = document.getElementById('password-input').value;

  // Reset the error message
  $('#login-error').html('');

  if (cooldown < 5) {
    $.post({
      url: "validateLogin.php",
      datatype: 'json',
      data: {
        'username': inputUsername,
        'password': inputPassword
      },
      success: function(data) {
        // Add error message to the error message box, or navigate
        $('#login-error').append(data);
      },
      alert: "Success!"
    });
  } else {
    $('#login-error').append("Please wait before attempting to login again");
  }

  cooldown += 1;
}

// Define isRunning as a global
var isRunning = false;

function validateRegister() {
  // Set username and password equal to input
  var inputUsername = document.getElementById('username-input').value;
  var inputPassword = document.getElementById('password-input').value;
  var confirmPassword = document.getElementById('password-confirm').value;
  var inputEmail = document.getElementById('email-input').value;

  // Reset the error message
  $('#register-error').html('');

  // Check that passwords match
  var passwordMatch = false;
  if (inputPassword == confirmPassword) {
    passwordMatch = true;
  } else {
    $('#register-error').html("Your passwords do not match")
  }

  if (cooldown < 5 && passwordMatch && !isRunning) {
    // To keep the query from being executed more than once at a time
    isRunning = true;
    // Query the script
    $.post({
      url: "sendRegistration.php",
      datatype: 'json',
      data: {
        'username': inputUsername,
        'password': inputPassword,
        'email': inputEmail
      },
      success: function(data) {
        // Add error message to the error message box, or navigate
        $('#register-error').html(data);
        // Reset the variable to allow a new query
        isRunning = false;
      },
      alert: "Success!"
    });
  } else if (cooldown > 5) {
    $('#register-error').html("Please wait before attempting to login again");
  }

  cooldown += 1;
}

// Reduce the cooldown every second
function reduceCooldown() {
  if (cooldown > 0) {
    cooldown -= 1;
  }
}

function logout() {
  var directory;
  if (window.location.host == "localhost") {
    directory = "/intrigueView";
  } else {
    directory = "";
  }
  $.post({
    url: directory + "/logout.php",
    success: function(data) {
      location.href= directory + "/index.php";
      console.log('logged out');
    },
    alert: "Success!"
  });
  return false;
}
