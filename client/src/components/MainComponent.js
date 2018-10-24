import React, { Component } from 'react';
import {Switch, Route, withRouter} from 'react-router-dom';
import { connect } from 'react-redux';

import Header from './HeaderComponent';
import Footer from './FooterComponent';
import Profile from './ProfileComponent';
import StudentList from './studentList/StudentList';
import SignupSheet from './SignupSheet';

import {  editProfile } from '../redux/actions/Profile'; 
import Login from './login/Login';
import PasswordForgotten from './passwordForgotten/PasswordForgotten'
import PasswordForgottenUpdate from './passwordForgotten/passwordForgottenUpdate/PasswordForgottenUpdate'
import Logout from './logout/Logout'
import StudentTaskView from './studentTaskView/StudentTaskView'
// import ProfileComponent from './ProfileComponent';
import StudentTeamComponent from './studentTeamComponent/StudentTeamComponent'
import ChangeHandleComponent from './changeHandle/ChangeHandleComponent';
import SignUpSheetComponent from './signUpSheet/SignUpSheetComponent'
import SubmittedContentEditComponent from './submittedContentEdit/SubmittedContentEditComponent';
import StudentQuizzesComponent from './studentQuizzes/StudentQuizzesComponent';
import GradesViewTeamComponent from './gradesViewTeam/GradesViewTeamComponent';
import GradesViewMyScores from './gradesViewMyScores/GradesViewMyScores';
import StudentReviewListComponent from './studentReviewList/StudentReviewListComponent';
import SuggestionsComponent from './suggestions/SuggestionsComponent';
import responseViewComponent from './responseView/responseViewComponent';
import ResponseEditComponent from './responseView/responseEdit/ResponseEditComponent';
import StudentTaskUpload from './studentTaskUpload/StudentTaskUpload'


const mapStateToProps = state => {
  return {
    profile: state.profile,
    institutions : state.institutions,
    studentTaskList : state.studentTaskList,
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
                { !this.props.loggedIn ? <Route path ='/' component={Login} /> : null }
                
                <Route path ='/profile' component={() => <Profile profile={this.props.profile} 
                      institutions = {this.props.institutions}
                      editProfile = {this.props.editProfile}/> } 
                      profileErr = { this.props.profile.errMess } />
                <Route path =  '/studentlist' 
                       component={() => <StudentList 
                                    studentsTeamedWith={this.props.studentTaskList.studentsTeamedWith}
                                    studentTasks = {this.props.studentTaskList.studentTasks}
                                    teamCourse = {this.props.studentTaskList.teamCourse}
                                    tasks_not_started = {this.props.studentTaskList.tasks_not_started}
                                    taskrevisions = {this.props.studentTaskList.taskrevisions}
                                    hasTopics = {this.props.studentTaskList.hasTopics}
                                    hasBadges = {this.props.studentTaskList.hasBadges}/>}/>
                <Route path = '/sign_up_sheet' component={SignupSheet}/>
                <Route path ='/logout' component={(Logout)} />
                <Route path ='/view_student_teams/:id' component={(StudentTeamComponent)} />
                <Route path ='/sign_up_sheet_list/:id' component={(SignUpSheetComponent)} />
                <Route path ='/submitted_content/:id' component={(StudentTaskUpload)} />
                <Route path ='/student_quizzes/:id' component={(StudentQuizzesComponent)} />
                <Route path ='/changeHandle/:id' component={(ChangeHandleComponent)} /> 
                <Route path ='/studentTaskView/:id' component={(StudentTaskView)} />
                <Route path ='/grades/view_team/:id' component={(GradesViewTeamComponent)} />
                <Route path ='/grades/view_my_scores/:id' component={(GradesViewMyScores)} />
                <Route path ='/student_review/list/:id' component={(StudentReviewListComponent)} />
                <Route path ='/suggestion/new/:id' component={(SuggestionsComponent)} />
                <Route path ='/response/view/:id' component={(responseViewComponent)} />
                <Route path ='/response/edit/:id' component={(ResponseEditComponent)} />
                <Route path ='/password_retrieval/forgotten' component={PasswordForgotten} />
                <Route path = '/password_edit/check_reset_url' component = {PasswordForgottenUpdate} />
                <Route path ='/home'  component={(HomePage)} /> 
              {/* <Redirect to="/home" /> */}
          </Switch>
            <Footer />
      </div>
    );
  }
}

export default withRouter(connect(mapStateToProps, mapDispatchToProps)(Main));
