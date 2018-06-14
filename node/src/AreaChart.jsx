import React from 'react';
import { Group } from '@vx/group';
import { curveBasis } from '@vx/curve';
import { LinePath } from '@vx/shape';
import { Threshold } from '@vx/threshold';
import { scaleTime, scaleLinear } from '@vx/scale';
import { AxisLeft, AxisBottom } from '@vx/axis';
import { GridRows, GridColumns } from '@vx/grid';
import { cityTemperature as data } from '@vx/mock-data';
import { timeFormat, timeParse } from 'd3-time-format';

const parseDate = timeParse('%Y%m%d');

// accessors
// const date = d => parseDate(d.date);
// const ny = d => d['New York'];
// const sf = d => d['San Francisco'];
const i = d => d.i;
const v = d => d.v;

export default class Thresholds extends React.Component {
  render() {
    const { width, height, margin, events } = this.props;
    
    var rawdata = this.props.joystickVals;
    if (rawdata.length > width) {
      rawdata = rawdata.slice(rawdata.length - width, rawdata.length);
    }
    var data = rawdata.map( function (cv, i, arr) {
        return {i:i, v:cv};
    });    

    if (width < 10) return null;
    // bounds
    const xMax = width - margin.left - margin.right;
    const yMax = height - margin.top - margin.bottom;

    // scales
    const xScale = scaleLinear({
      range: [0, 1000], 
      domain: [0, 1000]
    });
    const yScale = scaleLinear({
      range: [300, 700],
      domain: [0, 100]
    });

    return (
      <div>
        <svg width={width} height={height}>
          <rect x={0} y={0} width={width} height={height} fill="#f3f3f3" rx={14} />
          <Group left={margin.left} top={margin.top}>
            <GridRows scale={yScale} width={xMax} height={yMax} stroke="#e0e0e0" />
            <GridColumns scale={xScale} width={xMax} height={yMax} stroke="#e0e0e0" />
            <line x1={xMax} x2={xMax} y1={0} y2={yMax} stroke="#e0e0e0" />
            <AxisBottom top={yMax} scale={xScale} numTicks={width > 520 ? 10 : 5} />
            <AxisLeft scale={yScale} />
            <text x="10" y="10" transform="rotate(0)" fontSize={10}>
              Valence
            </text>
            <Threshold
              data={data}
              x={i}
              y0={0}
              y1={v}
              xScale={xScale}
              yScale={yScale}
              clipAboveTo={0}
              clipBelowTo={yMax}
              curve={curveBasis}
              belowAreaProps={{
                fill: 'red',
                fillOpacity: 0.4
              }}
              aboveAreaProps={{
                fill: 'green',
                fillOpacity: 0.4
              }}
            />
            <LinePath
              data={data}
              curve={curveBasis}
              x={i}
              y={v}
              xScale={xScale}
              yScale={yScale}
              stroke="#000"
              strokeWidth={1.5}
              strokeOpacity={0.8}
              strokeDasharray="1,2"
            />
            <LinePath
              data={data}
              curve={curveBasis}
              x={i}
              y={v}
              xScale={xScale}
              yScale={yScale}
              stroke="#000"
              strokeWidth={1.5}
            />
          </Group>
        </svg>
      </div>
    );
  }
}