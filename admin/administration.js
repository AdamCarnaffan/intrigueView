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
    url: "../rssFetch.php",
    data: {
      'sourceID': feedId
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
        'sourceID': feedId
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

function setAdmin(userID) {
  $.post({
    url: "setAdmin.php",
    data: {
      'userID': userID
    },
    success: function(data) {
      console.log(data);
      window.location.reload(true);
    },
    alert: "Success!"
  });
}

function submitFeed() {
  var newName = $('#addedFeedName').val();
  var newURL = $('#addedFeedURL').val();
  var newImage = $('#addedFeedImage').val();
  var newDesc = $('#addedFeedDesc').val();
  // Validate the source name
  if (newName.length < 4) {
    alert("The Source Name is not long enough");
    return false;
  }
  // Validate the image url, then notify if none is present
  if (newImage.length < 4) {
    if (!confirm("The Image URL is not required, though one is recommended. Continue regardless?")) {
      return;
    }
  }
  // Check for a description
  if (newDesc.length < 2) {
    alert("A short description is required to proceed");
    return;
  }
  // Begin pushing the new Feed to the Database
  $.post({
    url: "submitSourceFeed.php",
    data: {
      'name': newName,
      'url': newURL,
      'image': newImage,
      'desc': newDesc
    },
    dataType: 'json',
    success: function(data) {
      if (data.error) {
        // Log the error to console
        console.log(data.error.msg);
      } else {
        console.log('Feed Added, retreiving Data');
        refreshFeed(data.id, null);
        // ADD PLEASE WAIT OVERLAY
        // console.log(data.id);
        window.location.reload(true);
        // console.log(data.id);
      }
    },
    error: function(data) {
      console.log(data.responseText);
    },
    alert: "Success!"
  });
  return false;
}

function getRSS() {
  var selectionSize = $('#export-quantity').find(':selected').val();
  var feedSelection = $('#feed-selector').find(':selected').val();
  location.href = '../feed.php?size=' + selectionSize + '&selection=' + feedSelection;
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
        'feedID': feedId
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
      'entryID': entryId,
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
