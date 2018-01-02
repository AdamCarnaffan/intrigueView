function openInNewTab(url, entryID) {
  var tab = window.open(url, '_blank');
  tab.focus();
  $.post({
    url: 'viewEntry.php',
    data: {
      'entry': entryID
    }
  });
  return false;
}

function beginSearch() {
  // Reset Settings
  display = true;
  clearEntryDisplay();
  // Begin Search function
  search = $('#search-input').val();
  queryEntries(51, feedSelection);
  return false;
}

function beginLoading() { // Display a loading bar in the generated Canvas
  resizeCanvas();
  var loader = document.getElementById('loading-dots');
  var load = {
    dot: [],
  };
  // Calculate draw values for positioning
  var initalOffset = (loader.width - 0.18*loader.width)/2;
  var dotRadius = loader.width*0.01;
  // Generate the dots and draw the initial Shape (5 dots used)
  for (selector = 0;selector < 5; selector++) {
    load.dot.push(loader.getContext('2d'));
    load.dot[selector].translate(0.5, 0.5);
    load.dot[selector].beginPath();
    load.dot[selector].arc(4*dotRadius*selector+initalOffset,dotRadius*15,dotRadius,0, 2*Math.PI);
    load.dot[selector].fillStyle = 'rgb(40,136,167)';
    load.dot[selector].fill();
  }

  // After establishing inital display, redisplay using the same settings, though by adjusting one dot's size at a time

  var big = 0; // Determine which is big, the first is the one that starts big
  var roundBig = big;

  // Give the interval an ID to be terminated on load finish
  var loadingInterval = setInterval(loading,400);

  function loading() {
    loader.getContext('2d').clearRect(0,0,loader.width,loader.height);
    // Draw each dot again
    for (selector = 0;selector < 5;selector++) {
      load.dot[selector].beginPath();
      if (selector == roundBig) {
        makeBigCircle();
      } else {
        load.dot[selector].arc(4*dotRadius*selector+initalOffset,dotRadius*15,dotRadius,0, 2*Math.PI);
      }
      load.dot[selector].fill();
    }
    roundBig = big;
    return;
  }

  function makeBigCircle() {
    // Make the next circle big
    load.dot[big].arc(4*dotRadius*big+initalOffset,dotRadius*15,dotRadius*1.5,0,2*Math.PI);
    // Incriment for next pass
    if (big == 4) {
      big = 0;
    } else {
      big++;
    }
  }
  return loadingInterval;
}

function resizeCanvas() {
    canvas = document.getElementById('loading-dots');
    canvas.width = document.getElementById('feed-view').offsetWidth;
    canvas.height = canvas.width*0.3;
}

function resetQueries() {
  // Check the Tag Mode
  if (currentTagMode != 1) {
    currentTagMode = 1;
    $('#and-tag').toggleClass('toggle-button-class');
    $('#or-tag').toggleClass('toggle-button-class');
  }
  // Empty the search bar
  $('#search-input').val('');
  search = "";
  // Reset Tags
  queryTags = [];
  // Re-initialize the display
  clearEntryDisplay();
  queryEntries(51, feedSelection)
  getTags();
}

function queryFeeds(categoryID = 0) {
  // Display the loading dots
  $('#feed-view').append(loadingCanvas);
  var intervalLoadId = beginLoading();
  // Send the Query
  $.post({
    url: 'fetchFeeds.php',
    data: {
      'page': 1
    },
    success: function(data) {
      // Remove the loading dots
      $('#loading').remove();
      clearInterval(intervalLoadId);
      $('#feed-view').append(data);
    },
    error: function() {
      console.log('An error has occured loading the feeds');
    }
  });
}

function queryEntries(selection, feeds, scroll = false) {
  if (scroll) {
    scrollCooldown = 5
  }
  // Display the loading dots
  $('#feed-view').append(loadingCanvas);
  var intervalLoadId = beginLoading();
  // Process Tag Query String
  var queryTagString = queryTags.join('+');
  // Process the Feed List
  var feedIDList = feeds.join('+');
  // Send the Query
  $.post({
    url: "displayEntries.php",
    data: {
      'selection': selection,
      'currentDisplay': entriesDisplayed,
      'search': search,
      'tags': queryTagString,
      'tagMode': currentTagMode,
      'feedsList': feedIDList
    },
    dataType: 'json',
    success: function (data) {
      // Remove the loading dots
      $('#loading').remove();
      clearInterval(intervalLoadId);
      // Display the new data
      $('#feed-view').append(data.display);
      if (data.isFull == 'false') {
        display = false;
      }
      scrollCooldown = 0.8;
      entriesDisplayed += selection;
      // Apply the hover detection to all entries
      $(".hover-detect").hover( function() {
        $(this).data('leaving', false);
        $(this).siblings(".image-container").children(".extra-info").addClass("extra-info-hover");
      }, function() {
        $(this).data('leaving', true);
        var hoverObject = $(this);
        setTimeout( function() {
          closeInfo(hoverObject);
        }, 1000);
      });
      $(".in-extra-info").hover( function() {
        $(this).parents('.image-container').siblings('.hover-detect').data('leaving', false);
      });
      // Apply shadow styling in the extra info where necessary
      var shadowStyling = '<div class="synopsis-shadow"></div>';
      $('.extra-info-synopsis').each( function() {
        if ($(this).prop('scrollHeight') > $(this).prop('clientHeight')) {
          $(this).append(shadowStyling);
        }
      });
    },
    error: function() {
      // Remove the loading dots
      $('#loading').remove();
      clearInterval(intervalLoadId);
      // Display the new data
      $('#feed-view').append("<h5>An Error occured displaying the feed</h5>");
    },
    alert: "Success!",
    timeout: 10000 // 10 Second Timeout
  });
}

function closeInfo(extraInfoObject) {
  if (extraInfoObject.data('leaving') == true) {
    extraInfoObject.siblings(".image-container").children(".extra-info").removeClass("extra-info-hover");
  }
}

function returnToTop() {
  $('html, body').animate({
    scrollTop: '0px'}, 700);
  $('#return-button').remove();
  setTimeout( function() {
    returnButtonIsDisplayed = false;
  }, 3000);
}

function showBrowsePanel() {
  var nullVar = null;
  sessionStorage.removeItem("selectedFeeds"); // clear the browse data storage
  clearEntryDisplay();
  toggleTagging();
  toggleBrowseNavigation();
  $('#feed-view').html("<h3 class='feed-tile-align'>Browse Feeds to Find Content of Interest</h3>");
  feedSelection = [];
  viewingFeed = false;
  queryFeeds();
  return false;
}

function clearEntryDisplay() {
  $(document).scrollTop(0);
  $('#feed-view').html('');
  entriesDisplayed = 0;
}

function addTag(tagID) {
  queryTags.push(tagID);
  getTags();
  clearEntryDisplay();
  queryEntries(51, feedSelection);
  return false;
}

function removeTag(tagID) {
  // Remove the tagID from the queryTags array
  var index = queryTags.indexOf(tagID);
  queryTags.splice(index, 1);
  getTags();
  clearEntryDisplay();
  queryEntries(51, feedSelection);
  return false;
}

function getTags() {
  // Process Tag Query String To know which should be highlighted
  var tagString = queryTags.join('+');
  var feedString = feedSelection.join('+');
  // Empty the current Tags field
  $('#tag-collection').html('');
  $.post({
    url: 'displayTags.php',
    data: {
      'tags': tagString,
      'feeds': feedString
    },
    success: function(data) {
      $('#tag-collection').html(data);
    },
    alert: "success!"
  });
  return false;
}

function changeTagMode() {
  if (currentTagMode == 1) {
    currentTagMode = 2;
    $('#and-tag').toggleClass('toggle-button-class');
    $('#or-tag').toggleClass('toggle-button-class');
  } else {
    currentTagMode = 1;
    $('#or-tag').toggleClass('toggle-button-class');
    $('#and-tag').toggleClass('toggle-button-class');
  }
  if (queryTags.length > 0) {
    clearEntryDisplay();
    queryEntries(51, feedSelection);
  }
}

function setActiveFeed(myFeedMode, clickedButtonObject) {
  // Set the active feed if it differs, then complete a new query

  toggleFeedButton(clickedButtonObject);
  return false;
}

function toggleFeedButton(thisButton) {
  $('#feed-selection-bar').children('a').each(function() {
    if ($(this).hasClass('feed-selector-selected')) {
      $(this).toggleClass('feed-selector-selected');
    }
  });
  $(thisButton).toggleClass('feed-selector-selected');
}

function selectFeed(feedTileLink, feedID) {
  viewingFeed = true;
  feedSelection = [feedID];
  sessionStorage.setItem("selectedFeeds", feedSelection); // Save the current feed selected to a local session
  var tile = $(feedTileLink).parent().parent();
  tile.hide("slide", {direction: "left", distance: 1000}, 700);
  setTimeout(function() {
    clearEntryDisplay();
    toggleTagging();
    leftMarginSpace = $('#filter-display').css('margin-left');
    var leftMarginVal = leftMarginSpace.replace("px", "");
    if (leftMarginVal > 200) {
      toggleBrowseNavigation();
    } else {
      toggleBrowseNavigation("column");
    }
    queryEntries(51, feedSelection);
  }, 650);
  return false;
}

function toggleTagging() {
  if ($('#filter-display').length) {
    $('#filter-display').remove();
  } else {
    $('#navigator').after(taggingDisplay);
    // Toggle the AND selection
    $('#and-tag').toggleClass('toggle-button-class');
    getTags();
  }
  return;
}

function toggleBrowseNavigation(orientation = "row") {
  if ($('#browse-nav').length) {
    $('#browse-nav').remove();
  } else {
    $('#navigator').after(browseButtons);
  }
  if (orientation == "column") {
    $('#save-feed-button').css("top", '7rem');
    $('#save-feed-button').css("left", '1rem');
  }
  return;
}

function saveEntry(thisLink, entryID) {
  $.post({
    url: 'connectEntry.php',
    data: {
      'entryID': entryID
    },
    success: function() {
      $(thisLink).replaceWith("<div class='context-display'><span class='fa fa-check fa-context-style-added'></span></div>");
    },
    error: function() {
      console.log("An error has occured");
    }
  });
  return false;
}

function saveFeed(thisLink, feedID, isIcon = true) {
  $.post({
    url: 'connectFeed.php',
    data: {
      'feedID': feedID
    },
    success: function() {
      if (isIcon) {
        $(thisLink).replaceWith("<div class='context-display'><span class='fa fa-check fa-context-style-added'></span></div>");
      } else {
        $(thisLink).parent().css("background-color", "#009600");
      }
    },
    error: function() {
      console.log("An error has occured");
    }
  });
  return false;
}
