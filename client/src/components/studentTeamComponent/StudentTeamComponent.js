import React, { Component } from "react";
import { connect } from "react-redux";
import * as actions from "../../redux";
import { Loading } from "../UI/spinner/LoadingComponent";
import Aux from "../../hoc/Aux/Aux";
import { NavLink } from "react-router-dom";
import StudentTeamMemberComponent from "./studentTeamMember/studentTeamMemberComponent";
import JoinTeamRequestListComponent from "./joinTeamRequest/JoinTeamRequestListComponent";
import InvitationComponent from "./invitation/InvitationComponent";
import JoinTeamRequestListSentComponent from './joinTeamRequestListSent/JoinTeamRequestListSent'
import "../../assets/stylesheets/goldberg.css";
import RecievedInvitationComponent from "./recievedInvitation/recievedInvitationComponent";
import Modal from '../UI/Modal/Modal'
import EditNameComponent from './editName/EditNameComponent'
import '../../assets/stylesheets/flash_messages.css'
class StudentTeamComponent extends Component {
  state = { team_name: "", 
            user_name: "", 
            editNameModal: false,
            updateNameSuccess: false };

  componentDidMount() {
    this.props.fetchStudentsTeamView(this.props.match.params.id);
  }

  onTeamNameChangeHandler = e => {
    console.log('key was pressed', e.target.value)
    this.setState({ team_name: e.target.value });
  };

  onTeamNameSubmitHandler = e => {
    e.preventDefault();
    console.log("submit pressed");
    this.props.updateTeamName(this.props.student.id, this.state.team_name);
    this.setState({editNameModal: false, updateNameSuccess: true})

  };

  // handleBackButton = (e) => {
  //   e.preventDefault();
  //   this.props.history.goBack();
  // }
  onInvitationSubmitHandler = e => {
    e.preventDefault();
    // <%= form_tag :controller => 'invitations', :action => 'create' do %>
    //   <%= hidden_field_tag 'team_id', @student.team.id %>
    //   <%= hidden_field_tag 'student_id', @student.id %>
    //   <%= hidden_field_tag 'session[:dummy][:assignment_id]', @student.parent_id %>
  };

  editNameHandler = () => {
    this.setState({editNameModal: !this.state.editNameModal, updateNameSuccess: false})
  }

  render() {
    let output;
    let form;
    let body;
    let request;
    let invitations;
    let sendInvitaion;
    let waiting_listed;
    let received_invitations;
    let displayAvertisement;
    let displayAdvertisementHelper;
    let joinTeamRequestListSent;
  // <!--display the advertisement-->

  joinTeamRequestListSent = <JoinTeamRequestListSentComponent />

  if ( this.props.team && this.props.team.advertise_for_partner ) {
    displayAdvertisementHelper =  <Aux>
                                    {this.props.team.comments_for_advertisement}
                                    &nbsp;&nbsp;&nbsp;&nbsp;
                                    <NavLink to="#" >Edit </NavLink> 
                                    &nbsp;&nbsp;
                                    <NavLink to="#" >Delete </NavLink> 
                                  </Aux>
  } else {
    displayAdvertisementHelper = <NavLink to="#" >Create </NavLink> 
  }

  

  if( this.props.team && this.props.assignment_topics && this.props.team_topic ) {
    displayAvertisement =
                        <Aux> 
                         <b>Advertisement for teammates</b>
                          <br />
                          <table style={{width:"80%", align:"center" }} >
                            <tr>
                              <td>
                                {displayAdvertisementHelper}                              
                              </td>
                            </tr>
                          </table>
                        </Aux>
  }
  

    // <!--display a table of received invitation-->
  if (this.props.received_invs && this.props.received_invs.length > 0) {
      received_invitations= 
            <table style={{width:"80%", align:"center"}} >
            <h3>Received Invitations</h3>
            <tr style={{border: "1px outset #000000", padding: "10px 20px"}} >
              <th class="head">From </th>
              <th class="head">Team Name </th>
              <th class="head">Reply </th>
            </tr>
            { this.props.received_invs.map ( inv => <RecievedInvitationComponent  inv={inv} 
                                                                                  student={this.props.student} 
                                                                                  team = {this.props.team} 
                                                                                  assignment={this.props.assignment}/> ) }
          </table>
  }
  
// <!--waiting listed users on the same topic-->
    if (this.props.users_on_waiting_list && this.props.users_on_waiting_list.count > 0 ) {
      waiting_listed = <Aux>
                      <h3>Users waiting for this topic:</h3>
                      <table>
                        <tr>
                          <td><b>&nbsp; User id &nbsp; </b></td>
                          <td><b>&nbsp; Full name &nbsp; </b></td>
                          <td><b>&nbsp; Email &nbsp; </b></td>
                        </tr>
                        {this.props.users_on_waiting_list.map( user => <tr>
                            <td> &nbsp; {user.name} &nbsp; </td>
                            <td> &nbsp; {user.fullname} &nbsp; </td>
                            <td> &nbsp; {user.email} &nbsp; </td>
                          </tr>) }
                      </table>
                </Aux>
    }
    


    if (this.props.team && this.props.assignment.max_team_size > 1) {
      if (!this.props.team) {
        sendInvitaion = (
          <form onSubmit={this.onTeamNameSubmitHandler}>
            <h3>Name team 1</h3>
            <div className="form-group">
              <label for="team_name">team_name</label>
              <input
                type="text"
                className="form-control"
                placeholder="Team Name"
                value={this.state.team_name}
              />
            </div>
            <button type="submit" className="btn btn-primary">
              Name team
            </button>
          </form>
        )
      } else if (!this.props.team_full) {
        sendInvitaion = (
          <Aux>
            <b>Invite people</b>
              <form onSubmit={this.onInvitationSubmitHandler}>
                <table style={{ width: "80%", marginLeft: '10%' }}>
                  <tr>
                    <td>
                      Enter user login: <input value={this.state.user_name} />
                      <button type="submit" className="btn btn-secondary" value="Invite[]" style={{ marginLeft: "15px" }} > {" "}
                        Invite{" "}
                      </button>
                    </td>
                  </tr>
                </table>
              </form>
          </Aux>
        );
      }
    }

    if (this.props.send_invs && this.props.send_invs.length > 0) {
      invitations = (
        <Aux>
          <br />
          <br />
          <b>Sent invitations</b>
          <br />
          <br />
          {/* <!-- start invited people table --> */}
          <table style={{width:"80%", align:"center"}}>
            <tr style={{border: "1px outset #000000"}}>
              <th className="head">
                <b>Username</b>
              </th>
              <th className="head">
                <b>Full name</b>
              </th>
              <th className="head">
                <b>Email address</b>
              </th>
              <th className="head" align="center">
                <b>Status</b>
              </th>
            </tr>
            {this.props.send_invs.map(invitation => (
              <InvitationComponent inv={invitation} />
            ))}
          </table>
          <br />
        </Aux>
      );
      //   <!-- start invited people table -->
    }

    // <!--render partial for join team request-->
    if (this.props.student && this.props.team ) {
      request = (
        <JoinTeamRequestListComponent
          team_id={this.props.team.id}
          teams_user_id={this.props.student.id}
          assignment_id={this.props.assignment.id}
        />
      );
    }

    if (this.props.loaded) {
      output = <div style= {{ padding: '15px'}}> <h1>Team Information for {this.props.assignment.name}</h1></div>;

      if (!this.props.team) {
        form = (
          <div className="container-fluid text-left">
            You no longer have a team!
            <h3 style={{padding: '5px'}}>Name team 2</h3>
            <form onSubmit={this.onTeamNameSubmitHandler}>
              <div className="form-group" >
                <label for="team_name">team name</label>
                <div className="col-5" >
                  <input
                    type="text"
                    className="form-control"
                    placeholder="Team Name"
                    value={this.state.team_name}
                    onChange={this.onTeamNameChangeHandler}
                  />
                </div>
              </div>
              <button type="submit" className="btn btn-primary">
                Name Team
              </button>
            </form>
          </div>
        );
      } else {
        body = (
          <Aux>
            <b style={{ textAlign: "center" }}>Team Name: &nbsp;&nbsp;</b>
            {this.props.team.name} &nbsp;&nbsp;&nbsp;
            <NavLink to ="#" onClick={this.editNameHandler}> Edit name </NavLink>
            <br />
            {this.state.editNameModal ? <Modal show = {this.state.editNameModal} back= { this.editNameHandler} > 
                  {<EditNameComponent submitEditName = {this.onTeamNameSubmitHandler} 
                                      backButton = {this.editNameHandler} 
                                      team_name = {this.onTeamNameChangeHandler}
                                      value = {this.state.team_name}
                                      />} </Modal>: null}
            <br />
            <b>Team members</b>
            <br />
            <br />
            <table style={{ width: "80%", marginLeft: "10%" }}>
              <tr
                style={{ border: "1px outset #000000", padding: "10px 20px" }}
              >
                <th className="head">Username</th>
                <th className="head">Full name</th>
                {/* <!--<th className="head">Team-member role (duty)</th>--> */}
                <th className="head">Email address</th>
                {this.props.teammate_review_allowed ? (
                  <th className="head">Review action</th>
                ) : null}
              </tr>
              {this.props.participants.map(member => {
                console.log(member);
                return (
                  <StudentTeamMemberComponent
                                student_id = {this.props.student.id}
                                member={member}
                                assignment={this.props.assignment}
                                teammate_review_allowed = {this.props.teammate_review_allowed}
                  />
                );
              })}
              <tr>
                <td colspan="3">
                  <br />
                  <NavLink to="#" onClick={() => this.props.remove_participant_student_teams( this.props.student.id, this.props.team.id )}>Leave team</NavLink>
                </td>
              </tr>
            </table>
            {request}
          </Aux>
        );
      }
    } else {
      output = <Loading />;
    }

    return (
      <div class="wrapper">
        <div class="main">
          <div class="content">
            <div class="student_teams view">
              {this.state.updateNameSuccess ? <div className="flash_success alert alert-success alert-dismissible fade show" role="alert">
                                                <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                                                  <span aria-hidden="true">&times;</span>
                                                </button> Name updated successfully</div> : null}
              {output}
              {form}
              {body}
              {invitations}
              {sendInvitaion}
              {waiting_listed}
              {received_invitations}
              <br />
              {displayAvertisement}
              <br />
              {joinTeamRequestListSent}
              <br />
              <span onClick={() => this.props.history.goBack()} className="btn btn-outline-info">Back </span>
            </div>
          </div>
        </div>
      </div>
    );
  }
}

const mapStateToProps = state => {
  return {
    student: state.studentTeamView.student,
    current_due_date: state.studentTeamView.current_due_date,
    users_on_waiting_list: state.studentTeamView.users_on_waiting_list,
    teammate_review_allowed: state.studentTeamView.teammate_review_allowed,
    send_invs: state.studentTeamView.send_invs,
    recieved_invs: state.studentTeamView.recieved_invs,
    assignment: state.studentTeamView.assignment,
    assignment_topics: state.studentTeamView.assignment_topics,
    team: state.studentTeamView.team,
    participants: state.studentTeamView.participants,
    team_full: state.studentTeamView.team_full,
    team_topic: state.studentTeamView.team_topic,
    loaded: state.studentTeamView.loaded
  };
};

const mapDispatchToProps = dispatch => {
  return {
    fetchStudentsTeamView: student_id => dispatch(actions.fetchStudentsTeamView(student_id)),
    updateTeamName: (student_id, team_name) => dispatch(actions.updateTeamName(student_id, team_name)),
    remove_participant_student_teams: (student_id, team_id) => dispatch(actions.remove_participant_student_teams(student_id, team_id))
    }
  };

  export default connect(
  mapStateToProps,
  mapDispatchToProps
)(StudentTeamComponent);
