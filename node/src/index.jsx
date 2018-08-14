import React from 'react';
import ReactDOM from 'react-dom';
import './css/styles.css';
import { subscribeToJoystick, emit } from './api';

class ReplayPage extends React.Component {
  constructor(props) {
      super(props);

      subscribeToJoystick((err, joystickReading) => {
        // sanity check omits values outside of reasonable hardware range
        // should be recalibrated on each hardware change
        if (true) { //(joystickReading > 100 && joystickReading < 500) {
          //this.setState({joystickStabReading: Math.round(joystickReading/2 + this.state.joystickStabReading/2)});
          this.setState({joystickPosition: joystickReading});
          var arr = this.state.joystickVals;
          arr.push(joystickReading);
          this.setState({joystickVals: arr});
          var stab = joystickReading;
          this.responsiveAnalogRead(joystickReading);
          console.log('stab: ' + this.state.joystickStabReading);
          // if (this.state.joystickVals.length >= 10) {
          //   var sample = this.state.joystickVals.slice(this.state.joystickVals.length-5, this.state.joystickVals.length);
          //   sample.sort();
          //   stab = sample[2];
          // }
          // stab = Math.round(stab/2 + this.state.joystickStabReading/2)
          // this.setState({joystickStabReading: stab})

          //stab = 2*Math.round(stab/2);
          //this.setState({joystickStabReading: stab});

     //       var total = 0;
     //       for (var i = 1; i <= 7; i++) {
     //         total += this.state.joystickVals[this.state.joystickVals.length - i];
     //       }
     //       this.setState({joystickStabReading:  2*Math.round(Math.round(total/7)/2)});
     //       console.log('stab: ' + this.state.joystickStabReading);
     //}
     //     else {
     //      this.setState({joystickStabReading: this.state.joystickPosition});
     //     }
          // console.log(this.state.joystickVals);

          // joyRelPosition: relative position of joystick from ~(1 to 100)
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

      //layout states
      revealVideo: false,
      doneJump: false,
      playback: false,
      whichButton: false,
      vidJumpMin: 0,
      vidJumpSec: 0,
      debug: false,

      checkList1: " ",
      checkList2: " ",
      checkList3: " ",
      checkListDone: false,
      checkListIncorrect: false,

      // raw joystick and video data kept for debugging
      joystickPosition: -1,
      videoTime: -1,
      joystickVals: [],
      joystickStabReading: -1,
      // width/height kept in one place for dev purposes
      // ensure these match video properties
      videoWidth: 1096,
      videoHeight: 616,

      //smoothing constants
      SNAP_MULTIPLIER: 0.01,
      SLEEP_ENABLE: true,
      ACTIVITY_THRESHOLD: 2,
      EDGE_SNAP_ENABLE: true,
      ANALOG_RESOLUTION: 1024,

      //smoothing variables
      smoothValue: 0,
      errorEMA: 0,
      //lastActivityMS: 0,
      sleeping: false,

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

  checkListMsg() {
    if (this.state.checkListIncorrect == false) {
      return(<div className='CheckListIncorrectDiv'> </div>);}
    else {
      return(<div className='CheckListIncorrectDiv'>Missed one or more items. Please finish all items before continuing.</div>);
    }
    }

  checkList() {
    if (this.state.checkListDone == false) {
      return (
        <div>
          <div className='CheckListBg'/>
          <div className='CheckListDivCtr'>
          <div className='CheckListDivCtrIn'>
          <div className='CheckListDiv'>
          Check off after doing the following:</div>
        {this.checkListMsg()}
          <div className='CheckListDiv'>
          <button className='CheckButton' onClick={() => {
              if (this.state.checkList1 == " ") {this.setState({checkList1: "✓"});}
              else {this.setState({checkList1:" "});}}}>{this.state.checkList1}</button><div className='CheckListLabel'>
            You have checked that OBS is able to record <strong>desktop audio</strong> </div></div>
          <div className='CheckListDiv'>
          <button className='CheckButton' onClick={() => {
              if (this.state.checkList2 == " ") {this.setState({checkList2: "✓"});}
              else {this.setState({checkList2:" "});}}}>{this.state.checkList2}</button><div className='CheckListLabel'>
            You have started <strong>recording on OBS</strong></div></div>
          <div className='CheckListDiv'>
          <button className='CheckButton' onClick={() => {
              if (this.state.checkList3 == " ") {this.setState({checkList3: "✓"});}
              else {this.setState({checkList3:" "});}}}>{this.state.checkList3}</button><div className='CheckListLabel'>
            You have started <strong>recording on Netstation</strong></div> <br/></div>
          <div className='ListSubmitDiv'>
            <button className='CheckSubmitButton' onClick={() =>
                {if (this.state.checkList1 == "✓" && this.state.checkList2 == "✓" && this.state.checkList3 == "✓") {
                  this.setState({checkListDone: true});}
                else {
                  this.setState({checkListIncorrect: true});
                  }
            }}>Proceed</button>
          </div>
        </div>
        </div>
        </div>);
    }
    else {return (<div />);}
  }

  debugInfo() {
  if (this.state.debug == true) {
    return(
      <div className='CentreBottomPosition'>
        <p>Joystick: {this.state.joystickPosition} </p>
      </div>)
  }
  else {
  return <div />
  }
  }

  // // //
  //Responsive analog read algorithm from http://damienclarke.me/code/posts/writing-a-better-noise-reducing-analogread
  //TLDR: fixing jitter while maintaining responsive visual is not a trivial problem.
  //Straight median, mean and exponential filters all introduce too much lag whenever they're strong
  //enough to actually kill stationary jitter.
  //This more complicated solution does work though.
  responsiveAnalogRead(newVal) {
  // get current milliseconds
  // does this get used anywhere?
  //var ms = millis();
  var newValue = newVal;

  // if sleep and edge snap are enabled and the new value is very close to an edge, drag it a little closer to the edges. This'll make it easier to pull the output values right to the extremes without sleeping, and it'll make movements right near the edge appear larger, making it easier to wake up.
  if(this.state.SLEEP_ENABLE && this.state.EDGE_SNAP_ENABLE) {
    if(newValue < this.state.ACTIVITY_THRESHOLD) {
      newValue = newValue*2 - this.state.ACTIVITY_THRESHOLD;
    } else if(newValue > this.state.ANALOG_RESOLUTION - this.state.ACTIVITY_THRESHOLD) {
      newValue = newValue*2 - this.state.ANALOG_RESOLUTION + this.state.ACTIVITY_THRESHOLD;
    }
  }

  // get difference between new input value and current smooth value
  var diff = Math.abs(newValue - this.state.smoothValue);

  // measure the difference between the new value and current value over time
  // to get a more reasonable indication of how far off the current smooth value is
  // compared to the actual measurements
  this.setState({errorEMA: this.state.errorEMA + ((newValue - this.state.smoothValue) - this.state.errorEMA) * 0.4});

  // if sleep has been enabled, keep track of when we're asleep or not by marking the time of last activity and testing to see how much time has passed since then
  if(this.state.SLEEP_ENABLE) {
    // recalculate sleeping status
    // (asleep if last activity was over SLEEP_DELAY_MS ago)
    this.setState({sleeping: Math.abs(this.state.errorEMA) < this.state.ACTIVITY_THRESHOLD});
  }

  // if we're allowed to sleep, and we're sleeping
  // then don't update responsiveValue this loop
  // just output the existing responsiveValue
  if(this.state.SLEEP_ENABLE && this.state.sleeping) {
    return Math.floor(this.state.smoothValue);
  }

  // now calculate a 'snap curve' function, where we pass in the diff (x) and get back a number from 0-1. We want small values of x to result in an output close to zero, so when the smooth value is close to the input value it'll smooth out noise aggressively by responding slowly to sudden changes. We want a small increase in x to result in a much higher output value, so medium and large movements are snappy and responsive, and aren't made sluggish by unnecessarily filtering out noise. A hyperbola (f(x) = 1/x) curve is used. First x has an offset of 1 applied, so x = 0 now results in a value of 1 from the hyperbola function. High values of x tend toward 0, but we want an output that begins at 0 and tends toward 1, so 1-y flips this up the right way. Finally the result is multiplied by 2 and capped at a maximum of one, which means that at a certain point all larger movements are maximally snappy

  var snapCurve = function(x) {
    var y = 1 / (x + 1);
    y = (1 - y)*2;
    if(y > 1) {
      return 1;
    }
    return y;
  };

  // multiply the input by SNAP_MULTIPLER so input values fit the snap curve better.
  var snap = snapCurve(diff * this.state.SNAP_MULTIPLIER);

  // when sleep is enabled, the emphasis is stopping on a responsiveValue quickly, and it's less about easing into position. If sleep is enabled, add a small amount to snap so it'll tend to snap into a more accurate position before sleeping starts.
  if(this.state.SLEEP_ENABLE) {
    snap = snap*0.5 + 0.5;
  }

  // (update globalSnap so we can show snap in the output window)
  //globalSnap = snap;

  // calculate the exponential moving average based on the snap
  this.setState({smoothValue: this.state.smoothValue + (newValue - this.state.smoothValue) * snap});

  // ensure output is in bounds
  if(this.state.smoothValue < 0) {
    this.setState({smoothValue : 0});
  } else if(this.state.smoothValue > this.state.ANALOG_RESOLUTION - 1) {
    this.setState({smoothValue: this.state.ANALOG_RESOLUTION - 1});
  }

  // expected output is an integer
  //return Math.floor(smoothValue);
  this.setState({joystickStabReading: this.state.smoothValue});
}
  // // //


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
        {this.checkList()}

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

        {this.debugInfo()}

      </div>
    )
  };
}

ReactDOM.render(<ReplayPage/>, document.getElementById('replayPage'));
