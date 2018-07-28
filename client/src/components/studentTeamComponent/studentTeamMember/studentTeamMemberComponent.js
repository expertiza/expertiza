import React, { Component } from 'react'
import Aux from '../../../hoc/Aux/Aux'
import axios from '../../../axios-instance';
import {NavLink} from 'react-router-dom';
import {Loading} from '../../UI/spinner/LoadingComponent'
class studentTeamMemberComponent extends Component {
    state = {
        member : null,
        map: null,
        review: null,
        loaded: false
    }

    componentDidMount () {
        axios ({
            method : 'post',
            url : 'student_teams/getUserDetails',
            headers: { AUTHORIZATION: "Bearer " + localStorage.getItem('jwt') },
            data: { "user_id" : this.props.member.user_id,
                    "assignment_id" : this.props.assignment.id }
        })
        .then (response => this.setState({user : response.data.member, map : response.data.map, review: response.data.review , loaded: true}) )
    }

    render () {
        let output;
        let out;
        if( !this.state.review ) {
            out =  <td>  <NavLink to ="#" > Review </NavLink> </td>
        } else {
            out =  <td>
                        <NavLink to = "#" >View </NavLink>
                        &nbsp;&nbsp;
                        <NavLink to="#" >Edit </NavLink>
                    </td>
        }
        if(this.state.loaded) {
            output = <Aux>
                        <tr>
                            <td>{this.state.user.name }</td>
                            <td>{this.state.user.fullname }</td>
                            <td>{ this.state.user.email }</td>
                            {out}
                        </tr>
                   </Aux>
        } 
        return this.state.loaded ? output: <Loading />;
    }
}
export default studentTeamMemberComponent;