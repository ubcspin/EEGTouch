import React from 'react';
import { letterFrequency } from '@vx/mock-data';
import { Group } from '@vx/group';
import { Bar } from '@vx/shape';
import { scaleLinear, scaleBand } from '@vx/scale';

// Finally we'll embed it all in an SVG
export default (props) => {
  // We'll use some mock data from `@vx/mock-data` for this.
  var data = letterFrequency;
  
  var joystickVals = props.joystickVals.map(function(cv,i,arr){
    var obj = {i:i, val:cv};
    return obj;
  });
  console.log(joystickVals)
  // Define the graph dimensions and margins
  var width = props.width;
  var height = props.height;
  var margin = { top: 20, bottom: 20, left: 20, right: 20 };

  // Then we'll create some bounds
  var xMax = width - margin.left - margin.right;
  var yMax = height - margin.top - margin.bottom;

  // We'll make some helpers to get at the data we want
  // var x = d => d.letter;
  // var y = d => +d.frequency * 100;

  var x = d => d.i;
  var y = d => +d.val;


  // And then scale the graph by our data
  var xScale = scaleBand({
    rangeRound: [0, xMax],
    domain: joystickVals.map(x),
    padding: 0.4,
  });
  var yScale = scaleLinear({
    rangeRound: [yMax, 0],
    domain: [0, Math.max(...joystickVals.map(y))],
  });

  // Compose together the scale and accessor functions to get point functions
  var compose = (scale, accessor) => (joystickVals) => scale(accessor(joystickVals));
  var xPoint = compose(xScale, x);
  var yPoint = compose(yScale, y);
  return (
    <svg width={width} height={height}>
      {joystickVals.map((d, i) => {
        const barHeight = yMax - yPoint(d);
        return (
          <Group key={`bar-${i}`}>
            <Bar
              x={xPoint(d)}
              y={yMax - barHeight}
              height={barHeight}
              width={xScale.bandwidth()}
              fill='#fc2e1c'
            />
          </Group>
        );
      })}
    </svg>
  );
}