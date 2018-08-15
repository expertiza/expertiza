import React, { Component } from 'react';
import {  Label,  Col, Button, Form,FormGroup, Input, FormFeedback } from 'reactstrap';
import { Loading } from './UI/spinner/LoadingComponent';
import  ServerMessage  from './ServerMessComponent';
import TimezonePicker from 'react-bootstrap-timezone-picker';
// import 'react-bootstrap-timezone-picker/dist/react-bootstrap-timezone-picker.min.css';

class Profile extends Component {
    constructor(props){
        super(props);
        this.state = {
            institutions: this.props.institutions.institutions.institutions,
             profileform : {
                fullname: this.props.profile.profile.fullname,
                password: '',
                email: this.props.profile.profile.email,
                institution_id: this.props.profile.profile.institution_id,
                email_on_review: this.props.profile.profile.email_on_review,
                email_on_submission: this.props.profile.profile.email_on_submission,
                email_on_review_of_review: this.props.profile.profile.email_on_review_of_review,
                copy_of_emails: this.props.profile.profile.copy_of_emails,
                handle: this.props.profile.profile.handle,
                timezonepref: this.props.profile.profile.timezonepref,
             },
            aq : {
                 notification_limit: this.props.profile.aq===null?null:this.props.profile.aq.notification_limit
            },
            touched: {
                password: false,
                confirmpassword: false
            },
            confirmpassword: '',
            save: false,
        };
        this.handleInputChange = this.handleInputChange.bind(this);
        this.handleSubmit = this.handleSubmit.bind(this);
        this.handleBlur = this.handleBlur.bind(this);
        this.handleConfirmpassword= this.handleConfirmpassword.bind(this);
        this.handleNotificationChange = this.handleNotificationChange.bind(this);
        this.performedit = this.performedit.bind(this);
        this.handleChange = this.handleChange.bind(this);
}

validate(password, confirmpassword){
    const errors = {
        password: '',
        confirmpassword: ''
    }
    if(this.state.profileform.password !== this.state.confirmpassword){
        errors.confirmpassword = 'passwords do not match';
    }
    return errors;
}
handleSubmit(event) {
    this.setState({ save: true}, ()=>{console.log(this.state.save); this.performedit()});
    // this.props.editProfile(this.state.profileform, this.state.aq);
    event.preventDefault();
}

performedit(){
    this.props.editProfile(this.state.profileform, this.state.aq);
}
handleChange = (newValue) => {
    var profileform = {...this.state.profileform};
    profileform['timezonepref'] = newValue
    this.setState({ profileform });

}
handleConfirmpassword(event){
    const value = event.target.value;
    this.setState({
        confirmpassword: value
    });
}
handleInputChange(event) {
    const target = event.target;
    const value = target.type === 'checkbox' ? target.checked : target.value;
    const name = target.name;
    var profileform = {...this.state.profileform};
    profileform[name] = value;
    this.setState({profileform})
}
handleNotificationChange(event){
    const value = event.target.value;
    var aq = {...this.state.aq};
    aq['notification_limit'] =  value;
    this.setState({aq});
}
handleBlur = (field) => (evt) => {
    this.setState({
      touched: { ...this.state.touched, [field]: true },
    });
}
render(){
    const errors = this.validate(this.state.profileform.password, this.state.confirmpassword);
    if(this.state.institutions === undefined || this.state.institutions === null || this.state.profileform === undefined || this.state.profileform === null)
    {
            return(
                <div className ="profileform container-fluid">
                <div className="row row-content">
                       <div className=" col-12">
                           <h1>User Profile Information</h1>
                       </div>           
                        <Loading />
                    </div>
                </div>
            );
    }
    else{
        return(
          <div className ="profileform container-fluid">
             <div className="row row-content">
                    <div className ="col-12">
                        <ServerMessage  err = {this.props.profile.errMess} clicked={this.state.save}/>
                    </div>
                    <div className=" col-12">
                        <h1>User Profile Information</h1>
                    </div>   
                    <div className=" col-12 col-md-9">
                     <Form onSubmit={this.handleSubmit}>
                       <FormGroup row >
                              <Label htmlFor="fullname" md={3}>Full name (last, first[ middle]):</Label>
                              <Col md={3}>
                                  <Input type="text" id="fullname" name="fullname"
                                      value = { this.state.profileform.fullname }
                                      onChange={this.handleInputChange} 
                                       />
                              </Col>
                          </FormGroup><br />     
                          <FormGroup row>
                              <Label htmlFor="password" md={3}>Password</Label>
                              <Col md={3}>
                              <Input type="password" id="password" name="password"
                                       className="form-control"
                                       onChange={this.handleInputChange}
                                       onBlur = {this.handleBlur('password')}
                                       />
                              </Col>
                              </FormGroup><br /> 
                           <FormGroup row>
                              <Label htmlFor="confirmpassword" md={3}>Confirm password:</Label>
                              <Col md={3}>
                              <Input type="text" id="confirmpassword" name="confirmpassword"
                                      className="form-control"
                                      onChange = {this.handleConfirmpassword}
                                      valid = {errors.confirmpassword === ''}
                                      invalid = {errors.confirmpassword !== ''}
                                      onBlur = {this.handleBlur('confirmpassword')}
                                       />
                              <FormFeedback>{errors.confirmpassword}</FormFeedback>       
                              </Col>
                            </FormGroup><br /> 
                          <font >If password field is blank, the password will not be updated.</font>
                          <FormGroup row>
                              <Label htmlFor="email" md={3}>E-mail address: </Label>
                              <Col md={3}>
                              <Input type="text" id="email" name="email"
                                      className="form-control"
                                       value = {this.state.profileform.email}
                                       onChange={this.handleInputChange}
                                       />
                              </Col>
                            </FormGroup><br /> 
                         <FormGroup row>
                              <Label htmlFor="institution" md={3}>Institution: </Label>
                              <Col md={3}>
                                <select name="institution"  onChange={this.handleInputChange}
                                        className="form-control" selected = {this.state.institutions.filter((insti) => insti.id === this.props.profile.profile.institution_id)} >
                                        {
                                             this.state.institutions.map(opt => <option id={opt.name} key= {opt.name} >{opt.name} </option>) 
                                        }
                                    </select>
                              </Col>
                        </FormGroup><br /> 
                          <br /><br />
                          <FormGroup row>
                              <Col>
                                    <h5>E-mail options</h5>
                                    <p>Check the boxes representing the times when you want to receive e-mail.</p>
                              </Col>      
                              </FormGroup><br /> 
                          <FormGroup row>
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
                                    <input type="checkbox" name="email_on_review"
                                             className="form-check-input"
                                             defaultChecked={this.state.profileform.email_on_review}
                                             onChange={this.handleInputChange} />  
                                </div>    
                             </Col>
                             </FormGroup>
                         <FormGroup row>
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
                                    <input type="checkbox"  name="email_on_submission"
                                             className="form-check-input"
                                             checked={this.state.profileform.email_on_submission}
                                             onChange={this.handleInputChange}
                                              />  
                                </div>    
                             </Col>
                             </FormGroup>
                         <FormGroup row>
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
                                    <input type="checkbox" name="email_on_review_of_review"
                                             className="form-check-input" 
                                             checked={this.state.profileform.email_on_review_of_review}
                                             onChange={this.handleInputChange} />  
                                </div>    
                             </Col>
                             </FormGroup> 
                         <FormGroup row>
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
                                    <input type="checkbox" name="copy_of_emails"
                                             className="form-check-input" 
                                             checked={this.state.profileform.copy_of_emails}
                                             onChange={this.handleInputChange}/>  
                                </div>    
                             </Col>
                             </FormGroup>                        
                         <FormGroup row>
                            <Col>
                                <p><strong>Handle</strong></p>
                                    <p>A "handle" can be used to conceal your username from people who view your wiki pages. If you have a handle,
                                    your wiki account should be named after your handle instead of after your user-ID.  If you do not have a handle,
                                    your Expertiza user-ID will be used instead. A blank entry in the field below will cause the handle to be set back to your Expertiza user-ID.</p>
                                    <p><em>Note:</em>  By using this form, you are changing your <em>default handle</em>, which will be used for all
                                    <em>future</em> assignments.  To change your handle for a specific assignment, select that assignment and choose the <i>Change Handle</i>
                                    action.</p> 
                            </Col>
                            </FormGroup>   
                        <FormGroup row>
                            <Label htmlFor="handle" md={3}>Default Handle:</Label>
                            <Col md={3}>
                                <input type="text" id="handle" name="handle"
                                    placeholder={this.props.profile.profile.handle}
                                    value = {this.state.profileform.handle}
                                    onChange={this.handleInputChange}
                                    className="form-control"
                                    />
                            </Col>
                        </FormGroup><br /> 
                        <FormGroup row>
                            <Col>
                                <p>Specify a percent value greater than 0 in this field to receive notifications when a new review is 
                                        created which is outside the current range by the given amount.
                                        The value can be set on a per assignment, per questionnaire basis through the Manage Assignments page.
                                </p> 
                            </Col>
                            </FormGroup><br /> 
                        <FormGroup row>
                            <Label htmlFor="notification_limit" md={3}>Notification Percentage: </Label>
                            <Col md={3}>
                                <input type="text" id="notification_limit" name="notification_limit"
                                        className="form-control"
                                        value = {this.state.aq.notification_limit }
                                        onChange={this.handleNotificationChange}
                                    />
                            </Col>
                            <Label htmlFor="notification_percentage" > %</Label>
                            </FormGroup><br /> 
                        <FormGroup row>
                            <Label htmlFor="timezone" md={3}>Preferred Time Zone:</Label>
                            <Col md={3}>
                                {/* <input type="text" id="timezone" name="timezone"
                                    value = {this.state.profileform.timezonepref }
                                    onChange={this.handleInputChange}
                                    className="form-control"
                                    /> */}
                                <TimezonePicker
                                        absolute      = {false}
                                        defaultValue  = { this.state.profileform.timezonepref }
                                        placeholder   = "Select timezone..."
                                        onChange      = {this.handleChange}
                                />    
                            </Col>
                            </FormGroup><br />     
                            <FormGroup row> 
                                <Col md={{size:10}}>
                                    <Button type="submit" disabled={errors.confirmpassword!==''}>
                                        Save
                                    </Button>
                                </Col>
                            </FormGroup>                
                    </Form>
                 </div>     
            </div>      
         </div>
    );
    }
}
}

export default Profile;