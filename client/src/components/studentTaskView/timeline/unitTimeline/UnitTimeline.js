import React from 'react';
import { NavLink} from 'react-router-dom';
import  '../../../../assets/stylesheets/timeline.css';
import moment from 'moment'

const  UnitTimeline = (props) => {
        let output;
        let d1 = new Date();
        let d2 = new Date(props.tl.updated_at);
         if( d2 > d1 ) {
            output = <li className = "li">
                        <div className = "timestamp">
                            <p>{props.tl.updated_at}</p>
                        </div>
                        <div className = "status">
                            {props.tl.id ? <p><NavLink to={`/response/view/${props.tl.id}`}>{props.tl.label}</NavLink></p> : 
                                                props.tl.link ? <p><a href={props.tl.link}>{props.tl.label}</a> </p> :
                                                                     <p>{props.tl.label}</p> }
                        </div>
                    </li>
        } else {
            output = <li className = "li complete">
                        <div className = "timestamp">
                             {/* <p> { moment(new Date(props.tl.updated_at)).format('D MMM')}</p> */}
                             <p>{props.tl.updated_at}</p>
                        </div>
                        <div className = "status">
                        {props.tl.id ? <p><NavLink to={`/response/view/${props.tl.id}`}>{props.tl.label}</NavLink></p> : 
                                                props.tl.link ? <p><a href={props.tl.link}>{props.tl.label}</a> </p> :
                                                                     <p><a>{props.tl.label}</a></p> }
                        </div>
                    </li>

        }

        return output
}

export default UnitTimeline;