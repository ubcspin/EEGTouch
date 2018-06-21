import React from 'react';
import ReactDOM from 'react-dom';
// import BarGraph from "./BarGraph.jsx"
import AreaChart from "./AreaChart.jsx"

import { subscribeToTimer, subscribeToSensor, emit } from './api';

class Hello extends React.Component {
	constructor(props) {
  		super(props);

      subscribeToTimer((err, timestamp) => {
				this.setState({timestamp});
				//var jv = this.state.joystickLatest;
				//this.setState({joystickLatent: jv});
			});

  		subscribeToSensor((err, sensor) => {
				if (sensor.sensor == "A5") {
					this.setState({joystickLatest: sensor.voltage});
					this.setState({jSt: {
						width: sensor.voltage,
						height: '200px',
						backgroundColor: 'red'}
			  })
					// var arr = this.state.joystickVals;
					// var w = 340;
					// arr.push(sensor.voltage);
					// if (arr.length > w) {
			    //   arr = arr.slice(arr.length - w, arr.length);
			    // }
					// this.setState({joystickVals: arr});

					//this.handleJoystick(sensor.voltage);
				}
				this.setState({sensor: sensor.sensor, voltage: sensor.voltage});});
      //subscribeToJoystick((err, joystickval) => this.handleJoystick(joystickval));

      this.myVideo = React.createRef();

  		this.state = {
  			timestamp: 'no timestamp yet',
  			sensor: -1,
  			voltage: -1,
        playback: false,
        joystickVals: [],
				joystickLatest: -1,
				//joystickLatent: -1,
        width: 340,
        height: 240,
				jSt: {
					width: '10px',
					height: '200px',
					backgroundColor: 'red'}
		  }
	}

  // getData() {
  //   var data = this.state.joystickVals.map((cv, i, arr)=> {i: cv});
  //   return data;
  // }

  // handleJoystick(jv) {
  //   var arr = this.state.joystickVals;
  //   arr.push(jv);
  //   this.setState({joystickVals: arr});
	// 	this.setState({joystickLatest: jv});
  //   // console.log(this.state.joystickVals);
  // }

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
					<p>
						This is the joystick: {this.state.joystickLatest}
					</p>
					<div style={this.state.jSt} />
        </div>
      </div>
		)
	};
}


        // <BarGraph
        //   width={this.state.width}
        //   height={this.state.height}
        //   joystickVals={this.state.joystickVals}
        // />

				//		<div >
		    // <AreaChart
		    //       width={this.state.width}
		    //       height={this.state.height}
		    //       joystickVals={this.state.joystickVals}
				// 			joystickLatest={this.state.joystickLatest}
		    //       margin={{ top: 20, bottom: 20, left: 20, right: 20 }}
		    //     />

ReactDOM.render(<Hello/>, document.getElementById('hello'));
