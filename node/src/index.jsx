import React from 'react';
import ReactDOM from 'react-dom';
import Video from "./Video.jsx"

class Hello extends React.Component {
  render() {
    return (
    	<div>
    		<Video/>
    	</div>
    )
  }
}
 
ReactDOM.render(<Hello/>, document.getElementById('hello'));