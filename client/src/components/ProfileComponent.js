import React, { Component } from 'react';
import {  Label,  Col, Row } from 'reactstrap';
import {Control, LocalForm, Errors} from 'react-redux-form';
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
// componentDidMount() {
//     axios.get('http://localhost:3001/api/v1/profile/1.json')
//     .then(response => {
//         console.log(JSON.stringify(response))
//     })
//     .catch(error => console.log(error))
// }

render(){
    return(
         <div className ="profileform container-fluid">
             <div className="row row-content">
                    <div className=" col-12">
                        <h1>User Profile Information</h1>
                    </div>
                    <div>
                        <p>{this.props.profile}</p>
                    </div>    
                    <div className=" col-12 col-md-9">
                     <LocalForm onSubmit={(values) => this.handleSubmit(values)}>
                       <Row className="form-group">
                              <Label htmlFor="fullname" md={3}>Full name (last, first[ middle]):</Label>
                              <Col md={3}>
                                  <Control.text model=".fullname" id="fullnamename" name="fullname"
                                      placeholder="Full name"
                                      className="form-control"
                                    //   validators={{
                                    //       required, minLength: minLength(3), maxLength: maxLength(15)
                                    //   }}
                                       />
                                   {/* <Errors
                                      className="text-danger"
                                      model=".firstname"
                                      show="touched"
                                      messages={{
                                          required: 'Required',
                                          minLength: 'Must be greater than 2 characters',
                                          maxLength: 'Must be 15 characters or less'
                                      }}
                                    />   */}
                              </Col>
                          </Row><br />
                          <Row className="form-group">
                              <Label htmlFor="password" md={3}>Password</Label>
                              <Col md={3}>
                                  <Control.text model=".password" id="password" name="password"
                                      placeholder="Enter Password"
                                      className="form-control"
                                    //   validators={{
                                    //       required, minLength: minLength(3), maxLength: maxLength(15)
                                    //   }}
                                       />
                                  {/* <Errors
                                      className="text-danger"
                                      model=".lastname"
                                      show="touched"
                                      messages={{
                                          required: 'Required',
                                          minLength: 'Must be greater than 2 characters',
                                          maxLength: 'Must be 15 characters or less'
                                      }}
                                   /> */}
                              </Col>
                          </Row><br />
                          <Row className="form-group">
                              <Label htmlFor="confirmpassword" md={3}>Confirm password:</Label>
                              <Col md={3}>
                                  <Control.text model=".confirmpassword" id="confirmpassword" name="confirmpassword"
                                      placeholder="Confirm Password"
                                      className="form-control"
                                    //   validators={{
                                    //       required, minLength: minLength(3), maxLength: maxLength(15), isNumber
                                    //   }}
                                       />
                                  {/* <Errors
                                      className="text-danger"
                                      model=".telnum"
                                      show="touched"
                                      messages={{
                                          required: 'Required',
                                          minLength: 'Must be greater than 2 numbers',
                                          maxLength: 'Must be 15 numbers or less',
                                          isNumber: 'Must be a number'
                                      }}
                                   /> */}
                              </Col>
                          </Row><br />
                          <font >If password field is blank, the password will not be updated.</font>
                          <Row className="form-group">
                              <Label htmlFor="email" md={3}>E-mail address: </Label>
                              <Col md={3}>
                                  <Control.text model=".email" id="email" name="email"
                                      placeholder="Email"
                                      className="form-control"
                                    //   validators={{
                                    //       required, validEmail
                                    //   }}
                                       />
                                  {/* <Errors
                                      className="text-danger"
                                      model=".email"
                                      show="touched"
                                      messages={{
                                          required: 'Required',
                                          validEmail: 'Invalid Email Address'
                                      }}
                                   /> */}
                              </Col>
                          </Row><br />
                          <Row className="form-group">
                              <Label htmlFor="institution" md={3}>Institution: </Label>
                              <Col md={3}>
                                  <Control.text model=".institution" id="institution" name="institution"
                                      placeholder="Institution"
                                      className="form-control"
                                    //   validators={{
                                    //       required, validEmail
                                    //   }}
                                       />
                                  {/* <Errors
                                      className="text-danger"
                                      model=".email"
                                      show="touched"
                                      messages={{
                                          required: 'Required',
                                          validEmail: 'Invalid Email Address'
                                      }}
                                   /> */}
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
                             <Col md={{size:11}}>
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
                             <Col md={{size: 11}}>
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
                             <Col md={{size: 11}}>
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
                    </LocalForm>
                 </div>     
            </div>
            <br/><br />
            <div className = "row">
                <div className="col-12"> 
                    <p><strong>Handle</strong></p>
                    <p>A "handle" can be used to conceal your username from people who view your wiki pages. If you have a handle,
                    your wiki account should be named after your handle instead of after your user-ID.  If you do not have a handle,
                    your Expertiza user-ID will be used instead. A blank entry in the field below will cause the handle to be set back to your Expertiza user-ID.</p>
                    <p><em>Note:</em>  By using this form, you are changing your <em>default handle</em>, which will be used for all
                    <em>future</em> assignments.  To change your handle for a specific assignment, select that assignment and choose the <i>Change Handle</i>
                    action.</p> 
                </div>
            </div>
            <div className="row row-content">
                <div className="col-12">
                    <LocalForm onSubmit={(values) => this.handleSubmit(values)}>
                            <Row className="form-group">
                                    <Label htmlFor="handle" md={3}>Default Handle:</Label>
                                    <Col md={3}>
                                        <Control.text model=".handle" id="handle" name="handle"
                                            placeholder="Handle"
                                            className="form-control"
                                            //   validators={{
                                            //       required, minLength: minLength(3), maxLength: maxLength(15)
                                            //   }}
                                            />
                                        {/* <Errors
                                            className="text-danger"
                                            model=".firstname"
                                            show="touched"
                                            messages={{
                                                required: 'Required',
                                                minLength: 'Must be greater than 2 characters',
                                                maxLength: 'Must be 15 characters or less'
                                            }}
                                            />   */}
                                    </Col>
                                </Row><br />
                                <Row className="form-group">
                                    <Label htmlFor="handle" md={3}>Preferred Time Zone:</Label>
                                    <Col md={3}>
                                        <Control.text model=".timezone" id="timezone" name="timezone"
                                            placeholder="Timezone"
                                            className="form-control"
                                            //   validators={{
                                            //       required, minLength: minLength(3), maxLength: maxLength(15)
                                            //   }}
                                            />
                                        {/* <Errors
                                            className="text-danger"
                                            model=".firstname"
                                            show="touched"
                                            messages={{
                                                required: 'Required',
                                                minLength: 'Must be greater than 2 characters',
                                                maxLength: 'Must be 15 characters or less'
                                            }}
                                            />   */}
                                    </Col>
                                </Row><br />        
                            </LocalForm> 
                        </div>
                </div>                       
        </div>
    );
}
}

export default Profile;