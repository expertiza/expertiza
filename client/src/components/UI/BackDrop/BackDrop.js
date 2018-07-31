import React from 'react';
import './BackDrop.css'

const backDrop = ( props ) => (
        props.show ? <div className="BackDrop" onClick = {props.back}/> : null 
);

export default backDrop;