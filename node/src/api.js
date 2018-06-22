import openSocket from 'socket.io-client';
const socket = openSocket('http://localhost:3000');

function subscribeToTimer(cb) {
  socket.on('timer', timestamp => cb(null, timestamp));
  socket.emit('subscribeToTimer', 1000);
}

function subscribeToSensor(cb)  {
  socket.on('sensor', sensor => cb(null, sensor));
  // socket.emit('subscribeToTimer', 1000);
}

function emit(header, msg) {
	socket.emit(header, msg);
}
// function subscribeToJoystick(cb) {
// 	socket.on('joystickUpdate', joystickVal => cb(null, joystickVal));
// }

export { subscribeToTimer, subscribeToSensor, emit };
