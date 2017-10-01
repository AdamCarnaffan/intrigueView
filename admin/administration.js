// Feed Functions
function changeFeedURL(feedId) {
  confirm("This feature is not yet implemented. Sorry for any inconvenience");
  console.log(feedId);
}

function refreshFeed(feedId, target) {
  // Update the button to say Loading...
  $(target).html("Loading...");
  $(target).attr('disabled', 'disabled');
  // Query and perform the update
  $.post({
    url: "../getPocket.php",
    data: {
      'sourceId': feedId
    },
    success: function(data) {
      if (data.error) {
        // Log the error to console
        console.log(data.error.msg);
      }
      $(target).text('Refresh');
      $(target).removeAttr('disabled');
    },
    alert: "Success!"
  });
}

function deleteFeed(feedId) {
  // Post a confirmation notification, as this is permanent
  if (confirm("This action is permanent and cannot be undone. Are you sure you would like to proceed?")) {
    // Soft-delete the feed in the database
    $.post({
      url: "deleteSourceFeed.php",
      data: {
        'sourceId': feedId
      },
      success: function(data) {
        if (data.error) {
          // Log the error to console
          console.log(data.error.msg);
        } else {
          window.location.reload(true);
        }
      },
      alert: "Success!"
    });
  }
}

function submitFeed() {
  var newName = $('#addedFeedName').val();
  var newURL = $('#addedFeedURL').val();
  // Validate the source name
  if (newName.length < 4) {
    alert("The Source Name is not long enough");
    return false;
  }
  // Begin pushing the new Feed to the Database
  $.post({
    url: "submitSourceFeed.php",
    data: {
      'name': newName,
      'url': newURL
    },
    success: function(data) {
      if (data.error) {
        // Log the error to console
        console.log(data.error.msg);
      } else {
        window.location.reload(true);
      }
    },
    alert: "Success!"
  });
  return false;
}

// Entry Functions

// User Functions
