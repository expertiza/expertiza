import React from 'react'
import UnitTimelineComponent from './unitTimeline/UnitTimeline'
import '../../../assets/stylesheets/timeline.css'

const  TimelineComponent = (props) => {
        let output;
        if (props.timeline_list) {
            output = props.timeline_list.map(tl =>  <UnitTimelineComponent tl={tl}> </UnitTimelineComponent> )
        } else {
            output = null
        }
        ;

        return (
            <div className = "scrollable">
                <ul className = "timeline" id = "timeline">
                {output}     
                </ul>                      
            </div>
        )
}

export default TimelineComponent;