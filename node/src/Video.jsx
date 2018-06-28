import React from 'react';

export default (props) => {

  return (
    <div>
    <video width="1096" height="616">
      <source src="assets\testmovie.mov" type="video/mp4" />
    </video>
      <button onClick="playPause">Play</button> 
    </div>
  );
};
