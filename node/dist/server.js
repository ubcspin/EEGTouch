var app = require('express')();
var http = require('http').Server(app);

app.get('/', function(req, res){
  res.sendFile(__dirname + '/index.html');
});

app.get('/bundle.js', function(req, res){
  res.sendFile(__dirname + '/bundle.js');
});


http.listen(3000, function(){
  console.log('listening on *:3000');
});

var five = require("johnny-five");
var board = new five.Board();

board.on("ready", function() {
  var led = new five.Led(13);
  led.blink(500);
});