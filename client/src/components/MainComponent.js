import React, { Component } from 'react';
import {Switch, Route, Redirect, withRouter} from 'react-router-dom';
import { connect } from 'react-redux';

import Header from './HeaderComponent';
import Footer from './FooterComponent';
import Profile from './ProfileComponent';
import StudentList from './StudentList';
import SignupSheet from './SignupSheet';

import {  editProfile } from '../redux/ActionCreators'; 
import Login from './login/Login';
import PasswordForgotten from './passwordForgotten/PasswordForgotten'
import PasswordForgottenUpdate from './passwordForgotten/passwordForgottenUpdate/PasswordForgottenUpdate'
import Logout from './logout/Logout'
import StudentTaskView from './studentTaskView/StudentTaskView'
// import ProfileComponent from './ProfileComponent';
import StudentTeamComponent from './studentTeamComponent/StudentTeamComponent'
import ChangeHandleComponent from './changeHandle/ChangeHandleComponent';

const mapStateToProps = state => {
  return {
    profile: state.profile,
    institutions : state.institutions,
    studentsTeamedWith : state.studentsTeamedWith,
    studentTasks : state.studentTasks,
    loggedIn : state.auth.loggedIn
  }
}

const mapDispatchToProps = dispatch =>({
  //  *******************  fetchProfile, fetchInstitutions, fetchStudentsTeamedWith, fetchStudentTasks all these methods are added
  //  in async call to logIn ******
  editProfile: (profile,aq) =>{dispatch(editProfile(profile,aq))}
});

class Main extends Component {

  componentDidMount(){
    //  *******************  fetchProfile, fetchInstitutions, fetchStudentsTeamedWith, fetchStudentTasks all these methods are added 
    // in async call to logIn ******
    
  } 

   render() {
    const HomePage = () => {
        return(
                <div className="main_content" align="center">
                    <h1>Welcome!</h1>
                </div>
        );
      }
    return (
      <div  className="container-fluid">
          <Header />
          <Switch>
            { !this.props.loggedIn ? 
                    <div>
                      <Route exact path ='/' component={Login} />
                      <Route path ='/login' component={(Login)} />
                    </div> : null }
            
                {/* <Route path ='/' exact component={(HomePage)} /> */}
                <Route path ='/home'  component={(HomePage)} /> 
                <Route path ='/profile' component={() => <Profile profile={this.props.profile} 
                      institutions = {this.props.institutions}
                      editProfile = {this.props.editProfile}/> } 
                      profileErr = { this.props.profile.errMess } />
                <Route path =  '/studentlist' component={() => <StudentList studentsTeamedWith={this.props.studentsTeamedWith}
                      studentTasks = {this.props.studentTasks}/>}/>
                <Route path = '/sign_up_sheet' component={SignupSheet}/>
                <Route path ='/logout' component={(Logout)} />
                <Route path ='/view_student_teams/:id' component={(StudentTeamComponent)} />
                <Route path ='/changeHandle' component={(ChangeHandleComponent)} />
                <Route path ='/studentTaskView' component={(StudentTaskView)} />
                <Route path ='/password_retrieval/forgotten' component={PasswordForgotten} />
                <Route path = '/password_edit/check_reset_url' component = {PasswordForgottenUpdate} />
              <Redirect to="/home" />
          </Switch>
          <Footer />
      </div>
    );
  }
}

export default withRouter(connect(mapStateToProps, mapDispatchToProps)(Main));
