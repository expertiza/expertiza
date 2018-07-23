import React from 'react';
import { NavLink} from 'react-router-dom';
import  '../../../../assets/stylesheets/timeline.css';

const  UnitTimeline = (props) => {

   
        let output;
         if( props.tl.updated_at > new Date() ) {
             console.log('in unitttttt', props.tl)
            output = <li className = "li">
                        <div className = "timestamp">
                            <p> {this.props.tl.updated_at}></p>
                        </div>
                        <div className = "status">
                            {props.tl.id ? <p><NavLink to="#">{props.tl.label}</NavLink></p> : 
                                                props.tl.link ? <p><NavLink to="#">{props.tl.link}</NavLink> </p> :
                                                                     <p>{props.tl.label}</p> }
                        </div>
                    </li>
        } else {
            console.log('in unitttttt222', props.tl)
            output = <li className = "li complete">
                        <div className = "timestamp">
                            <p> {props.tl.updated_at}></p>
                        </div>
                        <div className = "status">
                        {props.tl.id ? <p><NavLink to="#">{props.tl.label}</NavLink></p> : 
                                                props.tl.link ? <p><NavLink to="#">{props.tl.link}</NavLink> </p> :
                                                                     <p>{props.tl.label}</p> }
                        </div>
                    </li>

        }

        return output
}

export default UnitTimeline;


//  tl[:label], controller: 'response', action: 'view', id: tl[:id], target: '_blank'
// tl[:label], tl[:link] 