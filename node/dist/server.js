////////////////////////////////////////////////////////////////////////////////
// Imports
//
////////////////////////////////////////////////////////////////////////////////
var five = require("johnny-five");
var path = require('path');

var app = require('express')();
var server = require('http').Server(app);
var io = require('socket.io')(server);

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

function message(msg) {
	if (msg.voltage > 0) {
		console.log("A" + msg.sensor + ": \t" + msg.voltage);
		io.emit('sensor', msg)
	}
}
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

	this.analogRead(0, function(voltage) {
		message({sensor: 0, voltage: voltage});
	});
	this.analogRead(1, function(voltage) {
		message({sensor: 1, voltage: voltage});
	});
	this.analogRead(2, function(voltage) {
		message({sensor: 2, voltage: voltage});
	});
	this.analogRead(3, function(voltage) {
		message({sensor: 3, voltage: voltage});
	});
	this.analogRead(4, function(voltage) {
		message({sensor: 4, voltage: voltage});
	});
	io.emit("ready","the board is ready");
});