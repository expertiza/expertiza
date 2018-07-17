import React, { Component } from 'react';
import { Card, CardTitle} from 'reactstrap';

class ServerMessage extends Component {
    constructor(props){
        super(props);
    }
render(){
    if(this.props.err === null && !this.props.saved)
    {
            return (
                <div className = "container">
                    <div className = "row">     
                    </div>
                </div>
            );
    }
    else if(this.props.err === 200){
        return (
            <div className = "container">
                <div className = "row"> 
                    <Card>
                        <CardTitle>Your profile was successfully updated.</CardTitle>
                    </Card>        
                </div>
            </div>
        );
    }
    else{
        return(
            <div className = "container">
                <div className = "row">     
                <Card>
                    <CardTitle>An error occurred and your profile could not updated.</CardTitle>
                </Card>    
                </div>
            </div>
        );
        }
}
}
export default ServerMessage;