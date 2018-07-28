import React, {Component} from 'react';
import {NavLink} from 'react-router-dom'
import TeamUserComponent from './teamUser/teamUserComponent';
import axios from '../../../axios-instance';

class RecievedInvitationComponent extends Component {
    state = {
        teamUsers : null
    }
    
    componentDidMount () {
        this.getTeamusers( this.props.inv.from_id)
    }

    getTeamusers = (user_id) => {
        axios ({
            method : 'post',
            url : 'student_teams/getTeamUsers',
            headers: { AUTHORIZATION: "Bearer " + localStorage.getItem('jwt') },
            data: { "user_id" : this.props.inv.from_id }
        })
        .then (response => {console.log('----',response.data )
                            this.setState({teamUsers : response.data.teamUsers}) })
  
    }

    render () {
        let recievedInv;
        let team_id;
        if (this.props.inv.reply_status === 'W') {
            recievedInv = 
                <tr>
                    <td>{ this.props.inv.from_user.name }</td>
                    <td>
                        { this.state.teamsusers.map( teamuser =>  <TeamUserComponent teamuser={teamuser} assignment={this.props.assignment}/>  )}
                    </td>
                    <td>
                    {team_id = this.props.team === null ? 0 : this.props.team.id }
                    <NavLink to="#" > Accept </NavLink>
                                {/* {:controller => 'invitations', :action => 'accept', :inv_id => inv.id, :student_id => @student.id, :team_id => @team_id}, */}
                                {/* {:onClick => "javascript: return confirm('Your topic (or place on waiting lists) will be relinquished if you accept the invitation. Do you want to continue?');"} */}
                    
                    <NavLink to="#" > Decline </NavLink> {/* {:controller => 'invitations', :action => 'decline', :inv_id => inv.id, :student_id => @student.id} */}
                    </td>
               </tr>
        }
        return recievedInv;
    }
}

export default RecievedInvitationComponent;