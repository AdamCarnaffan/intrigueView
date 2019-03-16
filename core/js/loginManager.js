// Listen for enter keypress to submit to validation function
// $(document).keypress(function(event) {
//   if (event.keyCode == 13) {
//     validateLogin();
//   }
// });

var mainPath = location.href;
v = mainPath.split('/');
v.splice(-1,1);
v.splice(0, 3);
mainPath = v.join('/');
mainPath = '/' + mainPath;

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
      url: "sendLogin.php",
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
  var input_username = $('#username-input').val();  // trim white-space on user
  var input_password = $('#password-input').val();
  var confirm_password = $('#password-confirm').val();
  var input_email = $('#email-input').val();
  var error = false;
  var check_username = /[\W]/;
  var check_password1 = /\s\t/;
  var check_password2 = /\d/;
  var check_password3 = /[A-z]/;
  [$('#username-error'), $('#password-error'), $('#confirm-password-error'), $('#email-error')].forEach(function (val) {
    val.html('');
  });
  if (input_username.length < 5) {
    $('#username-error').html('minimum username length is 5 characters');
    error = true;
  }
  else if (input_username.length > 20) {
    $('#username-error').html('maximum usernmame length is 20 characters');
    error = true;
  }
  else if (check_username.test(input_username) == true) {
    $('#username-error').html('invalid characters in username');
    error = true;
  }
  if (input_password.length < 6) {
    $('#password-error').html('minimum password length is 6 characters');
    error = true
  }
  else if (check_password1.test(input_password) == true ) {
    $('#password-error').html('invalid charactors in password');
    error = true;
  }
  else if ((check_password2.test(input_password) == false) || (check_password3.test(input_password) == false)) {
    $('#password-error').html('password should contain altleast 1 alphanumeric character');
    error = true;
  }
  if (input_password !== confirm_password) {  // validate password
    $('#confirm-password-error').html('passwords do not match');
    error = true;
  }
  if (input_email == '') {
    $('#email-error').html('invalid email');
    error = true;
  }
  if (error) {
    return false;
  }
}

function validateRegister2() {
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
      url: mainPath + "/bin/sendRegistration.php",
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
    directory = "/intrigueView/core";
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
