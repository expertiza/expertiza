import React, { Component } from 'react';
import Header from './HeaderComponent';
import Footer from './FooterComponent';
import Profile from './ProfileComponent';
import {Switch, Route, Redirect, withRouter} from 'react-router-dom';
import { connect } from 'react-redux';
import { fetchProfile, fetchInstitutions, editProfile } from '../redux/ActionCreators'; 

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

constructor(props){
    super(props);
  } 

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
      <div>
          <Header />
          <Switch>
            <Route path ='/home' component={(HomePage)} />
            <Route path ='/profile' component={() => <Profile profile={this.props.profile} institutions = {this.props.institutions} editProfile = {this.props.editProfile}/> } />
            <Redirect to="/home" />
          </Switch>
          <Footer />
      </div>
    );
  }
}

export default withRouter(connect(mapStateToProps, mapDispatchToProps)(Main));
