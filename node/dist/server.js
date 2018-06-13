////////////////////////////////////////////////////////////////////////////////
// Imports
//
////////////////////////////////////////////////////////////////////////////////
var five = require("johnny-five");
var path = require('path');

var app = require('express')();
var server = require('http').Server(app);
var io = require('socket.io')(server);

const fs = require('fs');

server.listen(3000);

////////////////////////////////////////////////////////////////////////////////
// Server code
//
////////////////////////////////////////////////////////////////////////////////
app.get('/', function(req, res) {
    res.sendFile(path.join(__dirname + '/index.html'));
});

app.get('/js/bundle.js', function(req, res) {
    res.sendFile(path.join(__dirname + '/js/bundle.js'));
});
// app.use(express.static('/js/')) // not working, supposedly sends folders

app.get('/assets/hack-this-poster.png', function(req, res) {
    res.sendFile(path.join(__dirname + '/assets/hack-this-poster.png'));
});

app.get('/assets/hypnotoad.mp4', function(req, res) {
    res.sendFile(path.join(__dirname + '/assets/hypnotoad.mp4'));
});

////////////////////////////////////////////////////////////////////////////////
// IO code
//
////////////////////////////////////////////////////////////////////////////////
var header = ["A0", "A1", "A2", "A3", "A4", "A5", "D5", "videoPlaying", "videoTimestamp", "timestamp"];
var state = {
	A0: -1,
	A1: -1,
	A2: -1,
	A3: -1,
	A4: -1,
	A5: -1,
	D5: -1,
	playing: false,
	videoTimestamp: -1,
}

var logTimer;
var session = Date.now();
var filepath = './logs/log_' + session + '.csv';
var delimiter = ",";


fs.open(filepath, 'w', (err, fd) => {
	if (err) {
		return console.error(err);
	}
	fs.close(fd, (err) => {
		if (err) throw err;
	});
	console.log("Opened " + filepath + " successfully!");
	log(header.join(delimiter));
	logTimer = setInterval(function(){
		var now = Date.now();
		var arr = [state.A0, state.A1, state.A2, state.A3, state.A4, state.D5, state.playing, state.videoTimestamp, now];
		var msg = arr.join(delimiter);
		log(msg);
	}, 1);
});

function handleMessage(msg) {
		updateSensors(msg);
		io.emit('sensor', msg)
}

// Unpack message to update the message state
function updateSensors(msg) {
	state[msg.sensor] = msg.voltage;
}

// MSG is a string???
function log(msg) {
	fs.appendFile(filepath, msg + "\n", function (err) {
	  if (err) throw err;
	  // console.log('Saved!');
	});
}

////////////////////////////////////////////////////////////////////////////////
// Socket code
//
////////////////////////////////////////////////////////////////////////////////
io.on('connection', (client) => {
  client.on('subscribeToTimer', (interval) => {
    console.log('client is subscribing to timer with interval ', interval);
    setInterval(() => {
      client.emit('timer', new Date());
    }, interval);
  });

  client.on('videoStart', function(){state.playing = true});
  client.on('videoTimestamp', function(ts) {
  	state.videoTimestamp = ts;
  	client.emit('joystickUpdate', state.A4);
  });
});

////////////////////////////////////////////////////////////////////////////////
// Arduino code
//
////////////////////////////////////////////////////////////////////////////////
var board = new five.Board({
		repl: false,
	});

board.on("ready", function() {
  	var led = new five.Led(13);
 	led.blink(500);

	this.pinMode(0, five.Pin.ANALOG);
	this.pinMode(1, five.Pin.ANALOG);
	this.pinMode(2, five.Pin.ANALOG);
	this.pinMode(3, five.Pin.ANALOG);
	this.pinMode(4, five.Pin.ANALOG);
	this.pinMode(5, five.Pin.ANALOG);
	var sensor = new five.Sensor.Digital(5);

	this.analogRead(0, function(voltage) {
		handleMessage({sensor: "A0", voltage: voltage});
	});
	this.analogRead(1, function(voltage) {
		handleMessage({sensor: "A1", voltage: voltage});
	});
	this.analogRead(2, function(voltage) {
		handleMessage({sensor: "A2", voltage: voltage});
	});
	this.analogRead(3, function(voltage) {
		handleMessage({sensor: "A3", voltage: voltage});
	});
	this.analogRead(4, function(voltage) {
		handleMessage({sensor: "A4", voltage: voltage});
	});
	this.analogRead(5, function(voltage) {
		handleMessage({sensor: "A4", voltage: voltage});
	});
	sensor.on("change", function() {
		handleMessage({sensor: "D5", voltage: this.value})
		console.log("digitalRead success " + this.value)
	})

	io.emit("ready","the board is ready");
});


