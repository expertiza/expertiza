import React, {Component} from 'react';
import {NavLink} from 'react-router-dom'
import TeamUserComponent from './teamUser/teamUserComponent';
import axios from '../../../axios-instance';
import * as actions from '../../../redux'
import {connect} from 'react-redux'

class ReceivedInvitationComponent extends Component {
    
    constructor(props){
        super(props)
        this.handleAccept = this.handleAccept.bind(this)
        this.handleDecline = this.handleDecline.bind(this)
    }

    handleAccept = (e, inv_id, team_id, student_id) => {
        this.props.onAccept(inv_id, team_id, student_id)
    }

    handleDecline = (e, inv_id, student_id) => {
        this.props.onDecline(inv_id, student_id)
    }
    
    
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
        let receivedInv;
        // eslint-disable-next-line
        let team_id = this.props.team === null ? 0 : this.props.team.id
        if (this.props.inv.reply_status === 'W') {
            receivedInv = 
                <tr>
                    <td>{ this.props.inv.from_user_name }</td>
                    <td>
                        {this.props.inv.team_name}
                    </td>
                    <td>
                    
                    <NavLink to="#"  onClick= { e => this.handleAccept(e,this.props.inv.id, team_id, this.props.student.id)}> Accept </NavLink>
                    
                    <NavLink to="#" onClick = { e => this.handleDecline(e,this.props.inv.id, this.props.student.id)} > Decline </NavLink> 
                    </td>
               </tr>
        }
        return receivedInv;
    }
}




export default ReceivedInvitationComponent;