import React from 'react';
import ReactDOM from 'react-dom';
// import BarGraph from "./BarGraph.jsx"
//import AreaChart from "./AreaChart.jsx"

import { subscribeToTimer, subscribeToSensor, emit } from './api';

class Hello extends React.Component {
  constructor(props) {
      super(props);

      subscribeToTimer((err, timestamp) => {
        this.setState({timestamp});
        //var jv = this.state.joystickLatest;
        //this.setState({joystickLatent: jv});
      });

      //backgroundColor: 'f44336';

      subscribeToSensor((err, sensor) => {
        if (sensor.sensor == "A5" && sensor.voltage > 400 && sensor.voltage < 700) {
          this.setState({joystickLatest: sensor.voltage});
          var jH = Math.min(188, Math.max(0, sensor.voltage - 428))/1.88;

        var jHue = 0;
        if (jH < 50) {jHue = 200}
        var jSat = Math.abs(jH - 50)*2 *0.7;
        var jLi = 50 - (100 - jSat/0.8)*0.1;
        var jHSL = "hsl(" + jHue + "," + jSat + "%," + jLi + "%)";

        if (jH < 50) {
          this.setState({jSt: {
            width: '8vw',
            height: (50-jH) + 'vh',
            backgroundColor: jHSL,
            top: '50%',
            right: '15%',
            position: 'absolute',
            zIndex: -1
          }
          })
        }
        else {
          this.setState({jSt: {
            width: '8vw',
            height: (jH-50) + 'vh',
            backgroundColor: jHSL,
            bottom: '50%',
            right:'15%',
            position: 'absolute',
            zIndex: -1
          }})
        }
        //   this.setState({jSt: {
        //     width: '100vw',
        //     height: '100vh',
        //     backgroundColor: jHSL,
        //     bottom:0,
        //     right:0,
        //     position: 'absolute',
        //     zIndex: -1}
        // })
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
        //joystickVals: [],
        joystickLatest: -1,
        //joystickLatent: -1,
        //width: 340,
        //height: 240,
        jSt: {
          width: '100vw',
          height: '100vh',
          backgroundColor: 'hsl(0,0%,50%)',
          bottom: 0,
          right: 0,
          position: 'absolute',
          zIndex: -1}
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
  //  this.setState({joystickLatest: jv});
  //   // console.log(this.state.joystickVals);
  // }

  getPlaybackMessage() {
    if (!this.state.playback) {
      return "Begin video playback...";
    }
    return "";
  }

  videoTimeCollect() {
     setInterval( function(){
       emit("videoTimestamp", this.refs.myVideo.currentTime);
     }.bind(this), 1000 / 30); //was 30
  }

  play() {
    var video = this.refs.myVideo;
    this.setState({playback: true});
    emit("videoStart", "videoStart");
    video.play();
    this.videoTimeCollect();
  }

  playButton() {
    const but = {backgroundColor: '#555555',
                border: 'none',
                color: 'white',
                padding: '15px 32px',
                textAlign: 'center',
                display: 'inline-block',
                fontSize: '16px',
                fontFamily: 'Helvetica, Verdana, sans-serif'
                }

    if (this.state.playback == false) {
      return (<button style={but} onClick={this.play.bind(this)}>Begin video playback...</button>);
    }
    else {
      return(<div />);
    }
  }

  render() {
      const aleft = {float:'left'};
      const aright = {float:'right', height: '100vh'};
      const aall = {width:'650px'};
      const acent = {position: 'fixed',
                    top: '50%',
                    left: '50%',
                    /* bring your own prefixes */
                    transform: 'translate(-50%, -50%)'}
      const abot = {position: 'fixed',
                    bottom: 0,
                    left: '50%',
                    transform: 'translate(-50%, 0)'
                    }
      const acentb = {position: 'fixed',
                      top: '75%',
                      left: '50%',
                      transform: 'translate(-50%, -50%)'
                      }

      return (
      <div style={aall}>
        <div style={aleft}>
        <div>
        <div style={acent}>
        <video width="1096" height="616" ref="myVideo">
          <source src="assets\testmovie.mov" type="video/mp4" />
        </video>
      </div>
      <div style={acentb}>
        {this.playButton()}
      </div>
      </div>
        <div className="App" style={abot}>
          <p className="App-intro">
          </p>
        </div>
      </div>
      <div style={aright}>
        <div>
          <div style={this.state.jSt} />
        </div>
        <div style={abot}>
        <p> Joystick: {this.state.joystickLatest} backgroundColor: {this.state.jSt.backgroundColor} </p>
        </div>
      </div>
      <div class="clear"></div>
    </div>
    )
  };
}

            //Timer: {this.state.timestamp} Joystick: {this.state.joystickLatest}

        // <BarGraph
        //   width={this.state.width}
        //   height={this.state.height}
        //   joystickVals={this.state.joystickVals}
        // />

        //    <div >
        // <AreaChart
        //       width={this.state.width}
        //       height={this.state.height}
        //       joystickVals={this.state.joystickVals}
        //      joystickLatest={this.state.joystickLatest}
        //       margin={{ top: 20, bottom: 20, left: 20, right: 20 }}
        //     />

ReactDOM.render(<Hello/>, document.getElementById('hello'));

