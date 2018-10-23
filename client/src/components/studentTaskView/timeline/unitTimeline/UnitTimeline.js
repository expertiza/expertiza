import React from 'react';
import { NavLink} from 'react-router-dom';
import  '../../../../assets/stylesheets/timeline.css';
import moment from 'moment'

const  UnitTimeline = (props) => {
        let output;
         if( props.tl.updated_at > new Date() ) {
            output = <li className = "li">
                        <div className = "timestamp">
                            <p>{moment(new Date(props.tl.updated_at)).format('MMMM Do YYYY, hh:mm')}</p>
                        </div>
                        <div className = "status">
                            {props.tl.id ? <p><NavLink to={`/response/view/${props.tl.id}`}>{props.tl.label}</NavLink></p> : 
                                                props.tl.link ? <p><NavLink to="#">{props.tl.link}</NavLink> </p> :
                                                                     <p>{props.tl.label}</p> }
                        </div>
                    </li>
        } else {
            output = <li className = "li complete">
                        <div className = "timestamp">
                             <p> { moment(new Date(props.tl.updated_at)).format('D MMM')}</p>
                        </div>
                        <div className = "status">
                        {props.tl.id ? <p><NavLink to={`/response/view/${props.tl.id}`}>{props.tl.label}</NavLink></p> : 
                                                props.tl.link ? <p><NavLink to="#">{props.tl.link}</NavLink> </p> :
                                                                     <p><a>{props.tl.label}</a></p> }
                        </div>
                    </li>

        }

        return output
}

export default UnitTimeline;