import React from 'react';
import ReactDOM from 'react-dom';
import Video from "./Video.jsx"
import { subscribeToTimer, subscribeToSensor } from './api';


class Hello extends React.Component {
	constructor(props) {
  		super(props);
  		subscribeToTimer((err, timestamp) => this.setState({timestamp}));
  		subscribeToSensor((err, sensor) => this.setState({sensor: sensor.sensor, voltage: sensor.voltage}));
  		this.state = {
  			timestamp: 'no timestamp yet',
  			sensor: -1,
  			voltage: -1,

		}
	}
	

	render() {
		return (
			<div>
			<Video/>
    		<div className="App">
      			<p className="App-intro">
      				This is the timer value: {this.state.timestamp}
      			</p>
      			<p>This is the Sensor A{this.state.sensor} value: {this.state.voltage}
      			</p>
    		</div>
			</div>
		)
	};
}
 
ReactDOM.render(<Hello/>, document.getElementById('hello'));