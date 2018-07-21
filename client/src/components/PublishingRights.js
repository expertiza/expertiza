import { Alert } from 'reactstrap';
import React, { Component } from 'react';

class PublishingRights extends Component {
    // constructor(props) {
    //     super(props);
    // }
    render(){
        return(
            <div>
                
                <Alert bsStyle="warning">Select an assignment from the list or set
                <strong> publishing rights </strong>
                for your work.
                </Alert>
               
            </div>
        );
    }
}
export default PublishingRights;