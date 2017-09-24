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

// Reduce the cooldown every second
function reduceCooldown() {
  if (cooldown > 0) {
    cooldown -= 1;
  }
}
