// Auto Select the First sort order for default sorting
var pastSelect;
selectSort("sortDef1");

var loadingCanvas = "<div id='loading'><canvas id='loading-dots' width='900' height='600'>Loading...</canvas></div>";


function selectSort(elementId) {
  // DRAWING & VISUALS
  if (pastSelect != null) {
    var removeTarget = document.getElementById(pastSelect);
    //removeTarget.classList.remove("active");
  }
  var selected = document.getElementById(elementId);
  //selected.classList.add("active");
  pastSelect = elementId;
  // RESORTING



  return false;
}

function fixTree() {

}

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
  // Generate Dot Objects (5 Dots)
  for (selector = 0;selector < 5; selector++) {
    load.dot.push(loader.getContext('2d'));
    load.dot[selector].translate(0.5, 0.5);
  }
  // Draw the initial Shape
  for (selector = 0;selector < 5; selector++) {
    load.dot[selector].beginPath();
    load.dot[selector].arc(4*dotRadius*selector+initalOffset,dotRadius*15,dotRadius,0, 2*Math.PI);
    load.dot[selector].fillStyle = 'rgb(40,136,167)';
    load.dot[selector].fill();
  }

  // After establishing inital display, redisplay using the same settings, though by adjusting one dot's size at a time

  var big = 0; // Determine which is big, the first is the one that starts big
  var roundBig = 0;

  // Give the interval an ID to be terminated on load finish
  var loadingInterval = setInterval(loading,400);

  function loading() {
    loader.getContext('2d').clearRect(0,0,loader.width,loader.height);
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
    return true;
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
