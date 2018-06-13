import React from 'react';

export default (props) => {

  return (
    <div>
    <video width="320" height="240">
      <source src="assets/hypnotoad.mp4" type="video/mp4" />
    </video>
      <button onClick="playPause">Play</button> 
    </div>
  );
};