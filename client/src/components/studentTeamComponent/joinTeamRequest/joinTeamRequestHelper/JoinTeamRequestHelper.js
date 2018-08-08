import React, { Component } from 'react';
import axios from '../../../../axios-instance'
import { Loading } from '../../../UI/spinner/LoadingComponent';

class JoinTeamRequestHelper extends Component {

    state = {
        user_name: null,
        loading: true
    }

    componentDidMount () {
        axios({
            method: 'post',
            url: 'student_teams/getUserNameFromParticipant',
            headers: {
                AUTHORIZATION: "Bearer " + localStorage.getItem('jwt')
            },
            data: {
                "participant_id" :this.props.join_team_request.participant_id  }
        }).then(response => this.setState({loading: false, user_name: response.data.user_name}))
        
    }

    inviteHandler = () => {
        // <%= form_tag :controller => 'invitations', :action => 'create' do %>
        // <%= hidden_field_tag 'team_id', team_id %>
        // <%= hidden_field_tag 'student_id', teams_user_id %>
        // <%= hidden_field_tag 'session[:dummy][:assignment_id]', Participant.find(join_team_request.participant_id).parent_id %>
        // <%= hidden_field_tag 'user[name]', User.find(Participant.find(join_team_request.participant_id).user_id).name %>
        // <%= hidden_field_tag 'participant_id', join_team_request.participant_id %>
        // <input type='submit' value='Invite'/>
        
    }

    declineHandler = () => {
        // button_to 'Decline', :controller => 'join_team_requests', :action => 'decline', :id=>join_team_request.id, :teams_user_id=>teams_user_id
    }
    render () {
        let output;
        if (!this.state.loading) {
            if (this.props.join_team_request.status ==='P' ) {
              output =  <tr>
                            <td> {this.state.user_name} </td>
                            <td> {this.props.join_team_request.comments} </td>
                            <td>
                                <table>
                                    <tr>
                                        <td> <button className="btn btn-lg btn-success" onClick={this.inviteHandler}>Invite</button></td>
                                        <td> <button className="btn btn-lg btn-danger" onClick={this.declineHandler}> Decline</button></td> 
                                    </tr>
                                </table>
                            </td>
                            <td> {this.props.join_team_request.created_at}</td>
                        </tr>
            }
        }

        return  this.state.loading ? <Loading/> : output
    }
}

export default JoinTeamRequestHelper;