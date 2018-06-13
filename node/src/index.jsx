import React from 'react';
import ReactDOM from 'react-dom';
import Video from "./Video.jsx"


import { subscribeToTimer, subscribeToSensor, subscribeToJoystick, emit } from './api';

import { letterFrequency } from '@vx/mock-data';
import { Group } from '@vx/group';
import { Bar } from '@vx/shape';
import { scaleLinear, scaleBand } from '@vx/scale';


// We'll use some mock data from `@vx/mock-data` for this.
const data = letterFrequency;

// Define the graph dimensions and margins
const width = 500;
const height = 500;
const margin = { top: 20, bottom: 20, left: 20, right: 20 };

// Then we'll create some bounds
const xMax = width - margin.left - margin.right;
const yMax = height - margin.top - margin.bottom;

// We'll make some helpers to get at the data we want
const x = d => d.letter;
const y = d => +d.frequency * 100;

// And then scale the graph by our data
const xScale = scaleBand({
  rangeRound: [0, xMax],
  domain: data.map(x),
  padding: 0.4,
});
const yScale = scaleLinear({
  rangeRound: [yMax, 0],
  domain: [0, Math.max(...data.map(y))],
});

// Compose together the scale and accessor functions to get point functions
const compose = (scale, accessor) => (data) => scale(accessor(data));
const xPoint = compose(xScale, x);
const yPoint = compose(yScale, y);


// Finally we'll embed it all in an SVG
function BarGraph(props) {
  return (
    <svg width={width} height={height}>
      {data.map((d, i) => {
        const barHeight = yMax - yPoint(d);
        return (
          <Group key={`bar-${i}`}>
            <Bar
              x={xPoint(d)}
              y={yMax - barHeight}
              height={barHeight}
              width={xScale.bandwidth()}
              fill='#fc2e1c'
            />
          </Group>
        );
      })}
    </svg>
  );
}


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
        joystickVals: []
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
    var width = 700,
    height = 300,
    margins = {left: 100, right: 100, top: 50, bottom: 50},
    title = "User sample",
    // chart series,
    // field: is what field your data want to be selected
    // name: the name of the field that display in legend
    // color: what color is the line
    chartSeries = [
      {
        field: 'BMI',
        name: 'BMI',
        color: '#ff7f0e'
      }
    ],
    // your x accessor
    x = function(d) {
      return d.index;
    }
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
        <BarGraph />
        
      </div>
		)
	};
}
 
ReactDOM.render(<Hello/>, document.getElementById('hello'));