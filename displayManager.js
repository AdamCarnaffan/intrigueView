function openInNewTab(url) {
  var tab = window.open(url, '_blank');
  tab.focus();
  return false;
}

function beginSearch() {
  // Reset Settings
  display = true;
  $(document).scrollTop(0);
  // Begin Search function
  search = $('#search-input').val();
  entriesDisplayed = 0;
  $.post({
    url: "fetchEntries.php",
    data: {
      'selection': 51,
      'currentDisplay': entriesDisplayed,
      'search': search
    },
    dataType: 'json',
    success: function (data) {
      $('#feed-view').html(data.display);
      entriesDisplayed = 51;
    },
    alert: "Success!"
  });
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
    canvas.width = document.getElementById('feed-content').offsetWidth;
    canvas.height = canvas.width*0.3;
}

function queryEntries(selection, scroll = false) {
  if (scroll) {
    cooldown = 5
  }
  // Display the loading dots
  $('#feed-view').append(loadingCanvas);
  var intervalLoadId = beginLoading();
  // Send the Query
  $.post({
    url: "fetchEntries.php",
    data: {
      'selection': selection,
      'currentDisplay': entriesDisplayed,
      'search': search
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
      cooldown = 0.8;
      entriesDisplayed += selection;
    },
    alert: "Success!"
  });
}

function returnToTop() {
  $('html, body').animate({
    scrollTop: '0px'}, 700);
  $('#return-button').remove();
  setTimeout( function() {
    returnButtonIsDisplayed = false;
  }, 3000);
}
