import React from 'react';
import { Player, ControlBar, ReplayControl,
  ForwardControl, CurrentTimeDisplay,
  TimeDivider, PlaybackRateMenuButton, VolumeMenuButton
} from 'video-react';

export default (props) => {
  return (
    <div>
    <p>It renderd</p>
    <Player
      poster="/assets/hack-this-poster.png"
    >
      <source src="/assets/hypnotoad.mp4" />  
    </Player>
    </div>
  );
};