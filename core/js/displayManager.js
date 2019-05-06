var mainPath;

$(document).ready( function() {
  mainPath = location.href.split('?')[0];
  splt = mainPath.split('/');
  splt.pop();
  mainPath = splt.join('/');
  if (mainPath.charAt(mainPath.length - 1) == '/') {
    mainPath = mainPath.substring(0, mainPath.length - 1);
  }
});


function openInNewTab(url, entryID) {
  var tab = window.open(url, '_blank');
  tab.focus();
  $.post({
    url: 'viewEntry.php',
    data: {
      'entry': entryID
    },
    success: function(data) {
      //console.log(data);
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
  queryEntries(51, feedSelection, false);
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
    load.dot[selector].fillStyle = 'rgb(56,170,206)';
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

function resetQueries(recommend) {
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
  queryEntries(51, feedSelection, recommend)
  getTags();
}

function queryFeeds(categoryID = 0) {
  //window.location.href = window.location.href.replace("#viewFeed", "");
  // Display the loading dots
  $('#feed-view').append(loadingCanvas);
  var intervalLoadId = beginLoading();
  // Send the Query
  $.post({
    url: 'displayFeeds.php',
    data: {
      'page': 1
    },
    success: function(data) {
      // Remove the loading dots
      $('#loading').remove();
      clearInterval(intervalLoadId);
      $('#feed-view').append(data);
      // Apply the hover detection to all feed tiles
      $(".hover-detect").hover( function() {
        $(this).data('leaving', false);
        $(this).parents(".feed-tile").addClass("feed-tile-shadow");
      }, function() {
        $(this).data('leaving', true);
        var hoverObject = $(this);
        hoverObject.parents(".feed-tile").removeClass("feed-tile-shadow");
        setTimeout( function() {
          closeInfo(hoverObject);
        }, 200);
      });
    },
    error: function() {
      this.tryCount++;
      if (this.tryCount <= this.retryLimit) {
        $.post(this);
        return;
      } else {
        // Remove the loading dots
        $('#loading').remove();
        clearInterval(intervalLoadId);
        // Display the new data
        $('#feed-view').append("<h5>An Error occured loading the feeds</h5>");
      }
    }
  });
}

function queryEntries(selection, feeds, displayRecommended, scroll = false) {
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
    url: mainPath + "/bin/displayEntries.php",
    data: {
      'selection': selection,
      'currentDisplay': entriesDisplayed,
      'search': search,
      'tags': queryTagString,
      'tagMode': currentTagMode,
      'feedsList': feedIDList,
      'recommend': displayRecommended
    },
    dataType: 'json',
    attempt: 0,
    retryLimit: 5,
    tryCount: 1,
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
        $(this).parents(".entry-tile").addClass("entry-tile-shadow");
      }, function() {
        $(this).data('leaving', true);
        var hoverObject = $(this);
        hoverObject.parents(".entry-tile").removeClass("entry-tile-shadow");
        setTimeout( function() {
          closeInfo(hoverObject);
        }, 200);
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
    error: function(XMLHttpRequest, textStatus, errorThrown) {
      this.tryCount++;
      if (this.tryCount <= this.retryLimit) {
        console.log(errorThrown);
        console.log("Retrying...");
        $.post(this);
        return;
      } else {
        // Remove the loading dots
        $('#loading').remove();
        clearInterval(intervalLoadId);
        // Display the new data
        $('#feed-view').append("<h5>An Error occured displaying the feed</h5>");
      }
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

function addTag(tagObject, tagID) {
  queryTags.push(tagID);
  $(tagObject).addClass("tag-active");
  tagObject.setAttribute("onclick", "return removeTag(this, " + tagID + ")");
  clearEntryDisplay();
  queryEntries(51, feedSelection, false);
  return false;
}

function removeTag(tagObject, tagID) {
  // Remove the tagID from the queryTags array
  var index = queryTags.indexOf(tagID);
  queryTags.splice(index, 1);
  $(tagObject).removeClass("tag-active");
  tagObject.setAttribute("onclick", "return addTag(this, " + tagID + ")");
  clearEntryDisplay();
  var noTags = (queryTags.length == 0) ? true : false;
  queryEntries(51, feedSelection, noTags);
  return false;
}

function getTags() {
  // Process Tag Query String To know which should be highlighted
  var tagString = queryTags.join('+');
  var feedString = feedSelection.join('+');
  // Empty the current Tags field
  $('#tag-collection').html('');
  $.post({
    url: mainPath + 'bin/displayTags.php',
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
    queryEntries(51, feedSelection, false);
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
  //tile.hide("slide", {direction: "left", distance: 1000}, 700);
  window.location.href = window.location.href + '#viewFeed';
  setTimeout(function() {
    clearEntryDisplay();
    toggleTagging();
    leftMarginSpace = $('#tag-display').css('margin-left');
    //var leftMarginVal = leftMarginSpace.replace("px", "");
    var leftMarginVal = 300;
    if (leftMarginVal > 200) {
      toggleBrowseNavigation();
    } else {
      toggleBrowseNavigation("column");
    }
    queryEntries(51, feedSelection, false);
  }, 650);
  return false;
}

function toggleTagging() {
  if ($('#tag-display').length) {
    $('#tag-display').remove();
  } else {
    $('#navigator').after(taggingDisplay);
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

function saveEntry(thisLink, entryID) {
  $.post({
    url: 'connectEntry.php',
    data: {
      'entryID': entryID
    },
    success: function() {
      changeAddButton(thisLink, true, entryID);
    },
    error: function() {
      console.log("An error has occured");
    }
  });
  return false;
}

function rmvEntry(thisLink, entryID) {
   $.post({
     url: 'deleteEntry.php',
     data: {
       'entryID': entryID
     },
     success: function() {
       changeAddButton(thisLink, false, entryID);
     },
     error: function() {
       console.log("An error has occured");
     }
   });
   return false;
}

function changeAddButton(btn, isAdding, id) {
   $(btn).attr("rt", parseInt($(btn).attr("rt")) + 45);
   $(btn).css("transform", "rotate(" + parseInt($(btn).attr("rt")) + "deg)");
   if (isAdding) {
      $(btn).attr("onclick", "return rmvEntry(this, " + id + ")");
      $(btn).find("span").addClass("fa-highlight-blue") // Need to add fa-highlight-blue
   } else {
      $(btn).attr("onclick", "return addEntry(this, " + id + ")");
      $(btn).find("span").removeClass("fa-highlight-blue") // Need to add fa-highlight-blue
   }
   return false;
}
