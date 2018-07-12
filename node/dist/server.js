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

app.get('/assets/video.mov', function(req, res) {
    res.sendFile(path.join(__dirname + '/assets/video.mov'));
});

// not serving stylesheet server-side because react packs it up for us

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
		var arr = [state.A0, state.A1, state.A2, state.A3, state.A4, state.A5, state.D5, state.playing, state.videoTimestamp, now];
		var msg = arr.join(delimiter);
		log(msg);
	}, 1);
});

function handleMessage(msg) {
		updateSensors(msg);
		if (msg.sensor == "A5") {
		io.emit('joystick', msg.voltage);
		//console.log("Emitting joystick reading: " + msg.voltage);
	}
}

// Unpack message to update the message state
function updateSensors(msg) {
	state[msg.sensor] = msg.voltage;
}

// MSG is a string???
// MSG is a seasoning
function log(msg) {
  // using synchronous append file
  // because otherwise it tries to open and append the same file
  // >2000 times simultaneously
  // this crashes the server on windows
  // behaviour which is generally frowned upon
  //
	fs.appendFileSync(filepath, msg + "\n", function (err) {
	  if (err) throw err;
	  // console.log('Saved!');
	});
	// console.log("Logging data");
}

////////////////////////////////////////////////////////////////////////////////
// Arduino code
//
////////////////////////////////////////////////////////////////////////////////
var board = new five.Board({
    // port must be explicitly named on windows for some reason
    // please replace the following with
    // whichever port ur board finds itself mounting to
    // or comment out if your OS is smart enough to know where things are
		port: "COM3",
		repl: false
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

	var outputPin = new five.Pin({pin:9, mode:1});
	var dumPin1 = new five.Pin({pin:7, mode:1});
	var dumPin2 = new five.Pin({pin:8, mode:1});
	var dumPin3 = new five.Pin({pin:6, mode:1});

	outputPin.high();
	dumPin1.high();
	dumPin2.high();
	dumPin3.high();

	// io.on('connection', (client) => {
 //  		client.on('sync', () => {
 //  			console.log("sending signal");
 //  			outputPin.high();
 //  			setTimeout(()=>{outputPin.low();}, 2000);
 //  		});
	// });

	// //tester code switch to trigger signal)
	// var inputPin = new five.Pin({pin:7, mode:0});
	// var highPin = new five.Pin({pin:8, mode:1});
	// highPin.high();
	// inputPin.on("high", ()=>{console.log("Input pin high");});



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
		handleMessage({sensor: "A5", voltage: voltage});
	});
	// sensor.on("change", function() {
	// 	handleMessage({sensor: "D5", voltage: this.value})
	// 	console.log("digitalRead success " + this.value)
	// 	if(this.value == 1) {
	// 		//console.log("sending signal to pin!");
	// 		//outputPin.high();
	// 		//outputPin.low();
	// 		//setTimeout(()=>{outputPin.low();}, 2000);
	// 	}
	// })

	//test code for test signal
	// sensor2.on("change", function() {
	// 	if (this.value == 1) {
	// 		console.log("sending signal to pin!");
	// 		//outputPin.write(1);
	// 		//outputPin.high();
	// 		//outputPin.low()
	// 	}
	// })

	io.emit("ready","the board is ready");
	//console.log("Emitting ready signal for J5");
});

////////////////////////////////////////////////////////////////////////////////
// Socket code
//
////////////////////////////////////////////////////////////////////////////////
io.on('connection', (client) => {

  client.on('videoStart', function(){state.playing = true;
    console.log("Received client request to start video");});
  client.on('videoTimestamp', function(ts) {
  	state.videoTimestamp = ts;
  	//console.log("Received client video timestamp: " + ts);
  });
  client.on('sync', () => {
  	console.log("sync request sent");
  	board.digitalWrite(9,0);
  	log("Sync at" + Date.now());
  	//board.digitalWrite(9,1);
  	setTimeout(()=>{board.digitalWrite(9,1);}, 10);

}); });
