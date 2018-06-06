import React from 'react';
import ReactDOM from 'react-dom';
import Video from "./Video.jsx"
import { subscribeToTimer } from './api';


class Hello extends React.Component {
	constructor(props) {
  		super(props);
  		subscribeToTimer((err, timestamp) => this.setState({timestamp}));
  		this.state = {
  			timestamp: 'no timestamp yet'
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
    		</div>
			</div>
		)
	};
}
 
ReactDOM.render(<Hello/>, document.getElementById('hello'));