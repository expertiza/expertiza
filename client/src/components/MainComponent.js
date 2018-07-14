import React, { Component } from 'react';
import Header from './HeaderComponent';
import Footer from './FooterComponent';
import Profile from './ProfileComponent';
import {Switch, Route, Redirect, withRouter} from 'react-router-dom';
import { connect } from 'react-redux';
import { fetchProfile, fetchInstitutions, editProfile } from '../redux/ActionCreators'; 
import Login from './login/Login';
import PasswordForgotten from './passwordForgotten/PasswordForgotten'
import PasswordForgottenUpdate from './passwordForgotten/passwordForgottenUpdate/PasswordForgottenUpdate'
import Logout from './logout/Logout'

const mapStateToProps = state => {
  return {
    profile: state.profile,
    institutions : state.institutions
  }
}

const mapDispatchToProps = dispatch =>({
  fetchProfile : () => {dispatch(fetchProfile())},
  fetchInstitutions: () => {dispatch(fetchInstitutions())},
  editProfile: (profile) =>{dispatch(editProfile(profile))}
});
class Main extends Component {

// constructor(props){
//     super(props);
//   } 

  componentDidMount(){
    this.props.fetchProfile();
    this.props.fetchInstitutions();
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
            <Route path ='/home' component={(HomePage)} />
            <Route path ='/profile' component={() => <Profile profile={this.props.profile} institutions = {this.props.institutions} editProfile = {this.props.editProfile}/> } />
            <Route path ='/login' component={(Login)} />
            <Route path ='/logout' component={(Logout)} />
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
