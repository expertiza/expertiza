import React from 'react';
import Aux from '../../../hoc/Aux/Aux'
import './Modal.css';
import BackDrop from '../BackDrop/BackDrop';

const modal = (props) => {
    // console.log('value of show in modal.js is  :', props.show);
    return  <Aux> 
                <BackDrop show= { props.show}  />
                <div className= "Modal"
                    style={{transform: props.show ? 'translateY(0)' : 'translateY(-100vh)',
                    opacity : props.show ? '1':0          
                    }}    >
                    {props.children}
                    
                 </div>
            </Aux>
}
// back = { props.back}

export default modal;