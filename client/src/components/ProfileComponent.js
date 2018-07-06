import React, { Component } from 'react';
import {  Label,  Col, Row, Button } from 'reactstrap';
import {Control, Form, Errors} from 'react-redux-form';
import axios from 'axios';

class Profile extends Component {
    constructor(props){
    super(props);
    this.handleSubmit = this.handleSubmit.bind(this);
}
handleSubmit(values) {
    console.log('Current State is: ' + JSON.stringify(values));
    alert('Current State is: ' + JSON.stringify(values));
}
componentWillMount(){
    //let a = this.props.institutions.institutions.institutions;
   // console.log("a is ======> " + a[0]);
}   
render(){
    return(
         <div className ="profileform container-fluid">
             <div className="row row-content">
                    <div className=" col-12">
                        <h1>User Profile Information</h1>
                    </div>   
                    <div className=" col-12 col-md-9">
                     <Form model="profileForm" onSubmit={(values) => this.handleSubmit(values)}>
                       <Row className="form-group">
                              <Label htmlFor="fullname" md={3}>Full name (last, first[ middle]):</Label>
                              <Col md={3}>
                                  <Control.text model=".fullname" id="fullname" name="fullname"
                                      placeholder= {this.props.profile.profile.fullname}  
                                      className="form-control"
                                       />
                              </Col>
                          </Row><br />
                          <Row className="form-group">
                              <Label htmlFor="password" md={3}>Password</Label>
                              <Col md={3}>
                                  <Control.text model=".password" id="password" name="password"
                                      className="form-control"
                                       />
                              </Col>
                          </Row><br />
                          <Row className="form-group">
                              <Label htmlFor="confirmpassword" md={3}>Confirm password:</Label>
                              <Col md={3}>
                                  <Control.text model=".confirmpassword" id="confirmpassword" name="confirmpassword"
                                      className="form-control"
                                       />
                              </Col>
                          </Row><br />
                          <font >If password field is blank, the password will not be updated.</font>
                          <Row className="form-group">
                              <Label htmlFor="email" md={3}>E-mail address: </Label>
                              <Col md={3}>
                                  <Control.text model=".email" id="email" name="email"
                                      placeholder={this.props.profile.profile.email}
                                      className="form-control"
                                       />
                              </Col>
                          </Row><br />
                          <Row className="form-group">
                              <Label htmlFor="institution" md={3}>Institution: </Label>
                              <Col md={3}>
                                <Control.select model=".institution" name="institution"
                                        className="form-control">
                                    {
                                        //console.log(this.state)
                                       //this.state.institutions.map(el => <option value={el.name} key={el.name}> {el.name} </option>)
                                    }
                                    </Control.select>
                              </Col>
                          </Row>
                          <br /><br />
                          <Row>
                              <Col>
                                    <h5>E-mail options</h5>
                                    <p>Check the boxes representing the times when you want to receive e-mail.</p>
                              </Col>      
                          </Row>
                         <Row className="form-group">
                             <Col md={{size:5}}>
                                 <div className="form-check">
                                    <Label check>
                                        <div>
                                            <span>When someone else <strong>reviews</strong> my work</span>
                                        </div>
                                    </Label>     
                                 </div>
                             </Col>
                             <Col md={{size: 1}}>
                                <div  className="form-check">
                                    <Control.checkbox model=".agree_on_review" name="agree_on_review"
                                             className="form-check-input" />  
                                </div>    
                             </Col>
                         </Row>
                         <Row className="form-group">
                             <Col md={{size: 5}}>
                                 <div className="form-check">
                                    <Label check>
                                        <div>
                                            <span>When someone else <strong>submits</strong> work I am assigned to review</span>
                                        </div>
                                    </Label>     
                                 </div>
                             </Col>
                             <Col md={{size: 1}}>
                                <div  className="form-check">
                                    <Control.checkbox model=".agree_on_submit" name="agree_on_submit"
                                             className="form-check-input" />  
                                </div>    
                             </Col>
                         </Row>
                         <Row className="form-group">
                             <Col md={{size: 5}}>
                                 <div className="form-check">
                                    <Label check>
                                        <div>
                                            <span>When someone else reviews one of my reviews (<strong>metareviews</strong> my work)</span>
                                        </div>
                                    </Label>     
                                 </div>
                             </Col>
                             <Col md={{size: 1}}>
                                <div  className="form-check">
                                    <Control.checkbox model=".agree_on_metareviews" name="agree_on_metareviews"
                                             className="form-check-input" />  
                                </div>    
                             </Col>
                         </Row> 
                         <Row className="form-group">
                             <Col md={{size: 5}}>
                                 <div className="form-check">
                                    <Label check>
                                        <div>
                                            <span>Send me copies of emails sent for assigments</span>
                                        </div>
                                    </Label>     
                                 </div>
                             </Col>
                             <Col md={{size: 1}}>
                                <div  className="form-check">
                                    <Control.checkbox model=".agree_on_metareviews" name="agree_on_metareviews"
                                             className="form-check-input" />  
                                </div>    
                             </Col>
                         </Row>                        
                        <Row>
                            <Col>
                                <p><strong>Handle</strong></p>
                                    <p>A "handle" can be used to conceal your username from people who view your wiki pages. If you have a handle,
                                    your wiki account should be named after your handle instead of after your user-ID.  If you do not have a handle,
                                    your Expertiza user-ID will be used instead. A blank entry in the field below will cause the handle to be set back to your Expertiza user-ID.</p>
                                    <p><em>Note:</em>  By using this form, you are changing your <em>default handle</em>, which will be used for all
                                    <em>future</em> assignments.  To change your handle for a specific assignment, select that assignment and choose the <i>Change Handle</i>
                                    action.</p> 
                            </Col>
                        </Row>    
                        <Row className="form-group">
                            <Label htmlFor="handle" md={3}>Default Handle:</Label>
                            <Col md={3}>
                                <Control.text model=".handle" id="handle" name="handle"
                                    placeholder="Handle"
                                    className="form-control"
                                    />
                            </Col>
                        </Row><br />
                        <Row>
                            <Col>
                                <p>Specify a percent value greater than 0 in this field to receive notifications when a new review is 
                                        created which is outside the current range by the given amount.
                                        The value can be set on a per assignment, per questionnaire basis through the Manage Assignments page.
                                </p> 
                            </Col>
                        </Row>
                        <Row className="form-group">
                            <Label htmlFor="notification_percentage" md={3}>Notification Percentage: </Label>
                            <Col md={3}>
                                <Control.text model=".notification_percentage" id="notification_percentage" name="notification_percentage"
                                    className="form-control"
                                    />
                            </Col>
                            <Label htmlFor="notification_percentage" > %</Label>
                        </Row><br /> 
                        <Row className="form-group">
                            <Label htmlFor="timezone" md={3}>Preferred Time Zone:</Label>
                            <Col md={3}>
                                <Control.text model=".timezone" id="timezone" name="timezone"
                                    placeholder={this.props.profile.profile.timezonepref}
                                    className="form-control"
                                    />
                            </Col>
                        </Row><br /> 
                        <Row className="form-group">
                            <Col md={{size:10}}>
                                <Button type="submit">
                                    Save
                                </Button>
                            </Col>
                        </Row>         
                    </Form>
                 </div>     
            </div>      
        </div>    
    );
}
}

export default Profile;