import React, {Component} from 'react';
import {NavLink} from 'react-router-dom'
import TeamUserComponent from './teamUser/teamUserComponent';
import axios from '../../../axios-instance';
import * as actions from '../../../redux/index'

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
        // eslint-disable-next-line
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
                    <NavLink to="#"  onClick= {this.props.acceptInvitsationToAssignment(this.props.inv.id, this.props.team.id, this.props.student.id)}> Accept </NavLink>
                    
                    <NavLink to="#" onClick = {this.props.declineInvitationToAssignment(this.props.inv.id, this.props.student.id)} > Decline </NavLink> 
                    </td>
               </tr>
        }
        return recievedInv;
    }
}


export const mapDispatchToProps = (dispatch) => {
    return {
        acceptInvitationToAssignment: (inv_id, team_id, student_id) => dispatch(actions.acceptInvitationToAssignment(inv_id, team_id, student_id)),
        declineInvitationToAssignment: (inv_id, student_id) => dispatch(actions.declineInvitationToAssignment(inv_id, student_id))
    }
}

export default RecievedInvitationComponent;