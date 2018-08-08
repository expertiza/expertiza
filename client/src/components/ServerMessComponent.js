import React, { Component } from 'react';
// import { Card, CardTitle} from 'reactstrap';

class ServerMessage extends Component {

render(){
    if(this.props.clicked === true)
    {
        return(
            <div className="flash_error alert alert-error">An error occurred and your profile could not updated.</div>
        );
    }
    else if(this.props.err === 200){
        return (
                <div className="flash_success alert alert-success">    Your profile was successfully updated.  </div>    
        );
    }
    else if(this.props.error)
    {
        return(
            <div className="flash_error alert alert-error" style={{ marginTop: '10px'}}> {this.props.error}</div>
        );
    }
    else {
            return(
                <div></div>
            );
        }
}
}
export default ServerMessage;