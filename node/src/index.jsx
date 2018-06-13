import React from 'react';
import ReactDOM from 'react-dom';
import Video from "./Video.jsx"
import { subscribeToTimer, subscribeToSensor, subscribeToJoystick, emit } from './api';
// require `react-d3-core` for Chart component, which help us build a blank svg and chart title.
var Chart = require('react-d3-core').Chart;
// require `react-d3-basic` for Line chart component.
var LineChart = require('react-d3-basic').LineChart;

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
        <Chart
      title={title}
      width={width}
      height={height}
      margins= {margins}
      >
      <LineChart
        margins= {margins}
        title={title}
        data={chartData}
        width={width}
        height={height}
        chartSeries={chartSeries}
        x={x}
      />
    </Chart>
      </div>
		)
	};
}
 
ReactDOM.render(<Hello/>, document.getElementById('hello'));