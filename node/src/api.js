import openSocket from 'socket.io-client';
const socket = openSocket('http://localhost:3000');

function subscribeToJoystick(cb)  {
  socket.on('joystick', joystickReading => cb(null, joystickReading));
}

function emit(header, msg) {
	socket.emit(header, msg);
}

export { subscribeToJoystick, emit };
