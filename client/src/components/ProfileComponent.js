import React, { Component } from 'react';
import { Button, Form, FormGroup, Label, Input, Col, Row } from 'reactstrap';
import { Link } from 'react-router-dom';
import {Control, LocalForm, Errors} from 'react-redux-form';

class Profile extends Component {
    constructor(props){
    super(props);

    this.handleSubmit = this.handleSubmit.bind(this);
}
handleSubmit(values) {
    console.log('Current State is: ' + JSON.stringify(values));
    alert('Current State is: ' + JSON.stringify(values));
}

render(){
    return(
        <div className ="container">
            <div className="row">
                < div className = "row row-content">
                    <div className="col-12">
                        <h3>User Profile Information</h3>
                    </div>
                </div>
            </div>        
        </div>


    );
}




}