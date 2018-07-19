import React, { Component } from 'react';
import { Card, CardTitle} from 'reactstrap';

class ServerMessage extends Component {

render(){
    if(this.props.err === null && !this.props.saved)
    {
            return (
                <div>
                </div>
            );
    }
    else if(this.props.err === 200){
        return (
                <div className="flash_success alert alert-success">    Your profile was successfully updated.  </div>    
        );
    }
    else{
            return(
                <div className="flash_error alert alert-error">An error occurred and your profile could not updated.</div>
            );
        }
}
}
export default ServerMessage;