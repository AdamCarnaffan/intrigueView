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
      console.log(data);
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
        console.log(data);
      }
    },
    alert: "Success!"
  });
  return false;
}

// Entry Functions

function getManageableEntries(button) {
  $(button).html("Loading...");
  $(button).attr("disabled", 'disabled');
  var feedId = $('#feedSelection').find(":selected").val();
  if (feedId == null) {
    $('#entriesDisplay').html("</br>There is nothing to display for the selected feed...");
  } else {
    $('#entriesDisplay').html(
      "<table id><tr><td>Image</td><td>Title</td><td>Options</td></tr>");
  }
  $(document).ready(function() {
    $.post({
      url: "getEntryManagement.php",
      data: {
        'feedId': feedId
      },
      success: function(data) {
        if (data.error) {
          // Log the error to console
          console.log(data.error.msg);
        } else {
          $('#entriesDisplay tbody:last').append(data);
        }
      },
      alert: "Success!"
    });
  });
  $(button).html("GO >");
  $(button).removeAttr('disabled');
}

function toggleFeatureEntry(button, entryId) {
  var featureStat = $(button).hasClass("entry-feature");
  $.post({
    url: "toggleFeatured.php",
    data: {
      'entryId': entryId,
      'isFeatured': featureStat
    },
    success: function(data) {
      if (data.error) {
        // Log the error to console
        console.log(data.error.msg);
      } else {
        if (featureStat) {
          $(button).removeClass("entry-feature");
        } else {
          $(button).addClass("entry-feature");
        }
      }
    },
    alert: "Success!"
  });
}

function deleteEntry(button, entryId) {
  if (confirm("Deleting an Entry is permanent. Would you like to proceed?")) {
    $.post({
      url: "deleteEntry.php",
      data: {
        'entryId': entryId
      },
      success: function(data) {
        if (data.error) {
          // Log the error to console
          console.log(data.error.msg);
        } else {
          // Remove the entry from view
          $(button).closest('tr').remove();
        }
      },
      alert: "Success!"
    });
  }
}

// User Functions
