<link href='styling/custom-styles.css' rel='stylesheet'>
<body onresize='resizeCanvas()'>
<div id='loading'>
  <canvas id='loading-dots' width='900' height='600'>Loading...</canvas>
</div>
<script>
var loader = document.getElementById('loading-dots');
var load = {
  dot: [],
};
// Calculate draw values for positioning
var initalOffset = (loader.width - 0.32*loader.width)/2;
var dotRadius = loader.width*0.02;
// Generate Dot Objects (5 Dots)
for (selector = 0;selector < 5; selector++) {
  load.dot.push(loader.getContext('2d'));
  load.dot[selector].translate(0.5, 0.5);
  load.dot[selector].fillStyle = 'rgb(40,136,167)';
}

// After establishing inital display, redisplay using the same settings, though by adjusting one dot's size at a time

var big = 0; // Determine which is big, the first is the one that starts big
var roundBig = 0; // Save the same variable, but one step back

// Give the interval an ID to be terminated on load finish
var loadingInterval = setInterval(loading,400);

function loading() {
  loader.getContext('2d').clearRect(0,0,loader.width,loader.height);
  for (selector = 0;selector < 5;selector++) {
    load.dot[selector].beginPath();
    if (selector == roundBig) {
      makeBigCircle();
    } else {
      load.dot[selector].arc(4*dotRadius*selector+initalOffset,loader.height/2,dotRadius,0, 2*Math.PI);
    }
    load.dot[selector].fill();
  }
  roundBig = big;
  return true;
}

function makeBigCircle() {
  // Make the next circle big
  load.dot[big].arc(4*dotRadius*big+initalOffset,loader.height/2,dotRadius*1.5,0,2*Math.PI);
  // Incriment for next pass
  if (big == 4) {
    big = 0;
  } else {
    big++;
  }
}

function resizeCanvas() {
    canvas = document.getElementById('loading-dots');
    canvas.width = document.getElementById('feed-view').width;
    canvas.height = canvas.width*(2/3);
}

</script>
</body>
