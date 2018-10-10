import React, {Component} from 'react';
import axios from '../../../../axios-instance';

class TeamUserComponent extends Component {
    state = {
        current_team: null
    }
    
    componentDidMount () {
        this.getCurrentTeam( )
    }

    getCurrentTeam  = (team_id, assignment_id) => {
        axios ({
            method : 'post',
            url : 'student_teams/getCurrentTeam',
            headers: { AUTHORIZATION: "Bearer " + localStorage.getItem('jwt') },
            data: { "team_id" : this.props.teamuser.id,
                    "assignment_id" : this.props.assignment.id }
        })
        .then(res => this.setState({current_team : res.data.current_team}))
    }

   
    render () {

        let team_name;
         if( this.state.current_team !== null) {
            team_name = <p> {this.state.current_team.name} </p>
         }

        return team_name;
        }
}

export default TeamUserComponent;