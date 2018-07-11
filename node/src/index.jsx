import React from 'react';
import ReactDOM from 'react-dom';
import './css/styles.css';
import { subscribeToJoystick, emit } from './api';

class ReplayPage extends React.Component {
  constructor(props) {
      super(props);

      subscribeToJoystick((err, joystickReading) => {
        // sanity check omits values outside of reasonable hardware range
        // shoudl be recalibrated on each hardware change
        if (true) { //(joystickReading > 100 && joystickReading < 500) {
          this.setState({joystickPosition: joystickReading});
          var arr = this.state.joystickVals;
          arr.push(joystickReading);
          this.setState({joystickVals: arr});
          if (this.state.joystickVals.length >= 10) {
            var total = 0;
            for (var i = 1; i <= 5; i++) {
              total += this.state.joystickVals[this.state.joystickVals.length - i];
            }
            this.setState({joystickStabReading:  Math.trunc(total/5)});
          }
          else {
            this.setState({joystickStabReading: this.state.joystickPosition});
          }
          // console.log(this.state.joystickVals);

          // joyRelHeight: relative position of joystick from ~(1 to 100)
          // used to calculate height, color of visualization
          // calculated based on min/max positions for analog input
          // should be recalibrated on each hardware change
          // 402 to 611
          var joyRelPosition =
            Math.min(210, Math.max(0, this.state.joystickStabReading - 775))/2.1;

          // calculate hue, saturation, lightnesss based on joystick position
          var joyHue = 0;
          if (joyRelPosition < 50) {joyHue = 200}
          var joySat = Math.abs(joyRelPosition - 50)*2 *0.7;
          var joyLight = 50 - (100 - joySat/0.8)*0.1;
          var joyHSL = "hsl(" + joyHue + "," + joySat + "%," + joyLight + "%)";

          // extend below centre and turn blue
          if (joyRelPosition < 50) {
            this.setState({joyBar: {
              width: '8vw',
              height: Math.max(0.5, (50-joyRelPosition)) + 'vh',
              backgroundColor: joyHSL,
              top: '50%',
              right: '10%',
              position: 'absolute',
              zIndex: 3
            }})
          }

          // extend above centre and turn red
          else {
            this.setState({joyBar: {
              width: '8vw',
              height: Math.max(0.5,(joyRelPosition-50)) + 'vh',
              backgroundColor: joyHSL,
              bottom: '50%',
              right:'10%',
              position: 'absolute',
              zIndex: 3}})}}});

    // persistent reference so video timestamps can be sent to server
    this.myVideo = React.createRef();
    this.handleChangeMin = this.handleChangeMin.bind(this);
    this.handleChangeSec = this.handleChangeSec.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);

    this.state = {
      revealVideo: false,
      doneJump: false,
      playback: false,

      // raw joystick and video data kept for debugging
      joystickPosition: -1,
      videoTime: -1,
      joystickVals: [],
      joystickStabReading: -1,
      // width/height kept in one place for dev purposes
      // ensure these match video properties
      videoWidth: 1096,
      videoHeight: 616,

      whichButton: false,
      vidJumpMin: 0,
      vidJumpSec: 0,

      // initialize default style for joystick bar
      joyBar: {
        width: '8vw',
        height: 1,
        backgroundColor: 'hsl(0, 0, 40)',
        bottom: '50%',
        right: '10%',
        position: 'absolute',
        zIndex: 3
      },
      // initialize default style for progress bar
      progressBar : {
        width: 0,
        height: 25,
        backgroundColor: '#000000'
      }
    }
  }

  videoTimeCollect() {
     setInterval( function(){
       var vidTimeNow = this.refs.myVideo.currentTime;
       this.setState({
         videoTime: vidTimeNow,
         // dynamically resize progress bar as video progresses
         progressBar : {
           width: this.state.videoWidth * vidTimeNow
            / this.refs.myVideo.duration,
           height: 25,
           backgroundColor: '#000000',
           left: '50%',
           top: '50%',
           transform: 'translate(-' + (this.state.videoWidth/2)  + 'px,'
            + ((this.state.videoHeight/2)+6) + 'px)',
           position: 'absolute',
           zIndex: 2
         }
      });
       // send video timestamp to server to sync with joystick input
       emit("videoTimestamp", vidTimeNow);
     }.bind(this), 1000 / 30);
  }

  play() {
    var video = this.refs.myVideo;
    video.currentTime = parseInt(this.state.vidJumpMin)*60 + parseInt(this.state.vidJumpSec);
    this.setState({playback: true});
    emit("videoStart", "videoStart");
    video.play();
    this.videoTimeCollect();
  }

  // Button covers screen
  // For using logger even when correct video isn't loaded
  // and you don't want to run a video anyway.

  revealVid() {
    this.setState({revealVideo: true});
  }

  syncButton() {

    if (this.state.revealVideo == false) {
      if (this.state.whichButton == false) {
        return (<button className='SyncButton' onClick={() => {
           this.setState({whichButton: true})
          emit("sync", "sync");}}> Sync </button>);
     }
     else {
      return (<button className='SyncButton2' onClick={() => {
           this.setState({whichButton: false})
          emit("sync", "sync");}}> Sync </button>);
     }
    }
    else {
      return (<div/>);
    }
  }

  coverButton() {
    if (this.state.revealVideo == false) {
            return (
          <div className='Cover'>
          {this.syncButton()}
          <button className='CoverButton'
            onClick={() => {this.setState({revealVideo: true})}}>
            Done syncing
             </button>
      </div>
      );}

    else {
      return (<div />);}
  }

  // play button disappears on click because video cannot be paused
  // play button is actually two buttons:
  //  one invisible button dynamically styled to video dimensions
  //    (so clicking anywhere on the video starts the video)
  //  another using stylesheet in order to use hover property
  //    (so play symbol opacity changes on mouse over, to show it's clickable)
  //  the play symbol button is on top
  //  yes, you can only ever click one of the buttons
  playButton() {
    const buttonStyle = {
        position: 'absolute',
        top: '50%',
        left: '50%',
        transform: 'translate(-50%,-50%)',
        width: this.state.videoWidth,
        height: this.state.videoHeight,
        backgroundColor: 'transparent',
        border: 'none'}

    if (this.state.playback == false) {
      return (<div>
                <button style={buttonStyle}
                  onClick={this.play.bind(this)} />
                <button className='PlayButton'
                  onClick={this.play.bind(this)}>►</button>
              </div>);
    }
    else {
      return(<div/>);
    }
  }

  handleChangeMin(event) {
    this.setState({vidJumpMin: event.target.value});
  }

    handleChangeSec(event) {
    this.setState({vidJumpSec: event.target.value});
  }

  handleSubmit(event) {
    //alert('Min: ' + this.state.vidJumpMin + ' Sec: ' + this.state.vidJumpSec);
    this.setState({doneJump: true});
    event.preventDefault();
    var timeSet = parseInt(this.state.vidJumpMin)*60 + parseInt(this.state.vidJumpSec);
    this.refs.myVideo.currentTime = timeSet; 
    this.setState({progressBar : {
           width: this.state.videoWidth * timeSet
            / this.refs.myVideo.duration,
           height: 25,
           backgroundColor: '#000000',
           left: '50%',
           top: '50%',
           transform: 'translate(-' + (this.state.videoWidth/2)  + 'px,'
            + ((this.state.videoHeight/2)+6) + 'px)',
           position: 'absolute',
           zIndex: 2
         }});
  }

  vidJump() {
  if (this.state.doneJump == false) {
    return (
    <div>
    <div className='VidJumpDiv'>
      <form onSubmit={this.handleSubmit}>
        <label>
        Video start time:
          <input type="number" min="0" max="99" step="1" value={this.state.vidJumpMin} onChange={this.handleChangeMin} className='VidJumpInput' />min
          <input type="number" min="0" max="60" step="1" value={this.state.vidJumpSec} onChange={this.handleChangeSec} className='VidJumpInput' />sec
        </label>
        <input type="submit" value="Set" className='VidJumpButton' />
      </form>
    </div>
    <div className='VidJumpCover' />
    </div>
    );}

  else {return (<div />);}
  }



  render() {
    // progress bar background is styled dynamically to use video width value
    const progressBg = {
        width: this.state.videoWidth,
        height: 25,
        backgroundColor: '#D3D3D3',
        left: '50%',
        top: '50%',
        transform: 'translate(-50%,' + ((this.state.videoHeight/2)+6) + 'px)',
        position: 'absolute'};

    return (
      <div>
        {this.syncButton()}

        {this.coverButton()}

        {this.vidJump()}

        <div className='Background' />

        <div className='VidBox'>
          <video width={this.state.videoWidth}
            height={this.state.videoHeight} ref="myVideo">
            <source src="assets\video.mov" type="video/mp4" />
          </video>
        </div>

        <div style={progressBg} />
        <div style={this.state.progressBar} />

        {this.playButton()}

        <div className='JoystickBg' />
        <div className='JoyBar' style={this.state.joyBar} />

      </div>
    )
  };
}

ReactDOM.render(<ReplayPage/>, document.getElementById('replayPage'));


// code to explicitly render joystick, video time values for debugging:
//        <div className='CentreBottomPosition'>
//        <p> Joystick: {this.state.joystickPosition}</p></div>
