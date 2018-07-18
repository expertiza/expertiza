import React, { Component } from 'react';
import Header from './HeaderComponent';
import Footer from './FooterComponent';
import Profile from './ProfileComponent';
import StudentList from './StudentList';
import SignupSheet from './SignupSheet';
import {Switch, Route, Redirect, withRouter} from 'react-router-dom';
import { connect } from 'react-redux';
import { fetchProfile, fetchInstitutions, editProfile, fetchStudentsTeamedWith, fetchStudentTasks } from '../redux/ActionCreators'; 
import Login from './login/Login';

const mapStateToProps = state => {
  return {
    profile: state.profile,
    institutions : state.institutions,
    studentsTeamedWith : state.studentsTeamedWith,
    studentTasks : state.studentTasks
  }
}

const mapDispatchToProps = dispatch =>({
  fetchProfile : () => {dispatch(fetchProfile())},
  fetchInstitutions: () => {dispatch(fetchInstitutions())},
  fetchStudentsTeamedWith : () => {dispatch(fetchStudentsTeamedWith())},
  fetchStudentTasks : () => {dispatch(fetchStudentTasks())},
  editProfile: (profile) =>{dispatch(editProfile(profile))}
});
class Main extends Component {

constructor(props){
    super(props);
  } 

  componentDidMount(){
    this.props.fetchProfile();
    this.props.fetchInstitutions();
    this.props.fetchStudentsTeamedWith();
    this.props.fetchStudentTasks();
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
      <div >
          <Header />
          <Switch>
            <Route path ='/home' component={(HomePage)} />
            <Route path ='/profile' component={() => <Profile profile={this.props.profile} 
                   institutions = {this.props.institutions}
                   editProfile = {this.props.editProfile}/> } 
                   profileErr = { this.props.profile.errMess } />
            <Route path = '/studentlist' component={() => <StudentList studentsTeamedWith={this.props.studentsTeamedWith}
                  studentTasks = {this.props.studentTasks}/>}/>
            <Route path = '/sign_up_sheet' component={SignupSheet}/>
            <Route path ='/login' component={(Login)} />
            <Redirect to="/home" />
          </Switch>
          <Footer />
      </div>
    );
  }
}

export default withRouter(connect(mapStateToProps, mapDispatchToProps)(Main));
