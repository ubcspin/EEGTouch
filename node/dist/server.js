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
	this.pinMode(5, five.Pin.DIGITAL);

	this.analogRead(0, function(voltage) {
		handleMessage({sensor: 0, voltage: voltage});
	});
	this.analogRead(1, function(voltage) {
		handleMessage({sensor: 1, voltage: voltage});
	});
	this.analogRead(2, function(voltage) {
		handleMessage({sensor: 2, voltage: voltage});
	});
	this.analogRead(3, function(voltage) {
		handleMessage({sensor: 3, voltage: voltage});
	});
	this.analogRead(4, function(voltage) {
		handleMessage({sensor: 4, voltage: voltage});
	});
	this.digitalRead(5, function(voltage) {
		handleMessage({sensor: 5, voltage: voltage})
	})

	io.emit("ready","the board is ready");
});

////////////////////////////////////////////////////////////////////////////////
// IO code
//
////////////////////////////////////////////////////////////////////////////////
var state = {
	A0: -1,
	A1: -1,
	A2: -1,
	A3: -1,
	A4: -1,
	D5: -1
}

var logTimer;
var session = Date.now();
var filepath = './logs/log_' + session + '.txt';
var delimiter = ",";

fs.open(filepath, 'w', (err, fd) => {
	if (err) {
		return console.error(err);
	}
	fs.close(fd, (err) => {
		if (err) throw err;
	});
	console.log("Opened " + filepath + " successfully!");
	var header = ["A0", "A1", "A2", "A3", "A4", "D5", "timestamp"];
	log(header.join(delimiter));
	logTimer = setInterval(function(){
		var now = Date.now();
		var arr = [state.A0, state.A1, state.A2, state.A3, state.A4, state.D5, now];
		var msg = arr.join(delimiter);
		log(msg);
	}, 1);
});

function message(msg) {
	if (msg.voltage > 0) {
		console.log("A" + msg.sensor + ": \t" + msg.voltage);
		updateSensors(msg);
		io.emit('sensor', msg)
	}
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

