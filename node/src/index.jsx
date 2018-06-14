import React from 'react';
import ReactDOM from 'react-dom';
import BarGraph from "./BarGraph.jsx"

import { subscribeToTimer, subscribeToSensor, subscribeToJoystick, emit } from './api';




class Hello extends React.Component {
	constructor(props) {
  		super(props);
  		
      subscribeToTimer((err, timestamp) => this.setState({timestamp}));
  		subscribeToSensor((err, sensor) => this.setState({sensor: sensor.sensor, voltage: sensor.voltage}));
      subscribeToJoystick((err, joystickval) => this.handleJoystick(joystickval));

      this.myVideo = React.createRef();

  		this.state = {
  			timestamp: 'no timestamp yet',
  			sensor: -1,
  			voltage: -1,
        playback: false,
        joystickVals: [],
        width: 340,
        height: 240, 
		  }
	}

  getData() {
    var data = this.state.joystickVals.map((cv, i, arr)=> {i: cv});
    return data;
  }

  handleJoystick(jv) {
    var arr = this.state.joystickVals;
    arr.push(jv);
    this.setState({joystickVals: arr});
    // console.log(this.state.joystickVals);
  }

	getPlaybackMessage() {
    if (!this.state.playback) {
      return "Begin video playback...";
    }
    return "Playing...";
  }

  videoTimeCollect() {
    setInterval( function(){
      emit("videoTimestamp", this.refs.myVideo.currentTime);
    }.bind(this), 1000 / 30);
  }

  play() {
    var video = this.refs.myVideo;
    this.setState({playback: true});
    emit("videoStart", "videoStart");
    video.play();
    this.videoTimeCollect();
  }

	render() {

      return (
      <div>
        <video width="320" height="240" ref="myVideo">
          <source src="assets/hypnotoad.mp4" type="video/mp4" />
        </video>
        <button onClick={this.play.bind(this)}>{this.getPlaybackMessage()}</button>
        <div className="App">
          <p className="App-intro">
            This is the timer value: {this.state.timestamp}
          </p>
          <p>
            This is the Sensor A{this.state.sensor} value: {this.state.voltage}
          </p>
        </div>
        <BarGraph 
          width={this.state.width}
          height={this.state.height}
          joystickVals={this.state.joystickVals}
        />
        
      </div>
		)
	};
}
 
ReactDOM.render(<Hello/>, document.getElementById('hello'));