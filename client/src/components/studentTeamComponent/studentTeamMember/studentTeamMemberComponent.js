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
        TeammateReviewQuestionnaire: null,
        studentIdEqualCurrentUserId: false,
        loaded: false,
    }

    componentDidMount () {
        axios ({
            method : 'post',
            url : 'student_teams/getUserDetails',
            headers: { AUTHORIZATION: "Bearer " + localStorage.getItem('jwt') },
            data: { "student_id": this.props.student_id,
                     "member_id" : this.props.member.id,
                     "user_id" : this.props.member.user_id,
                    "assignment_id" : this.props.assignment.id,
                    "teammate_review_allowed" : this.props.teammate_review_allowed }
        })
        .then (response => {this.setState({member : response.data.member, map : response.data.map, review: response.data.review , loaded: true ,
                                             TeammateReviewQuestionnaire: response.data.TeammateReviewQuestionnaire, studentIdEqualCurrentUserId: response.data.studentIdEqualCurrentUserId
                                         })
                            console.log(response.data) })
    }


    render () {
        let output;
        let out;
        if( this.state.loaded) {
            if(this.props.teammate_review_allowed ) {
                if (this.state.TeammateReviewQuestionnaire && !this.state.studentIdEqualCurrentUserId) {
                    if( !this.state.review ) {
                        out =  <td>  <NavLink to ={`response/view/${this.state.map.id}`}  > Review </NavLink> </td>
                    } else {
                        out =  <td>
                                    <NavLink to={`/response/view/${this.state.review.id}`}  >View </NavLink>
                                    &nbsp;&nbsp;
                                    <NavLink to={`/response/edit/${this.state.review.id}`} >Edit </NavLink>
                                </td>
                    }
                }
                
            }

            output = <Aux>
                        <tbody>
                            <tr>
                                <td>{this.state.member.name }</td>
                                <td>{this.state.member.fullname }</td>
                                <td>{ this.state.member.email }</td>
                                {out}
                            </tr>
                        </tbody>
                    </Aux>
        }
       
        return this.state.loaded ? output: <Loading />;
    }
}
export default studentTeamMemberComponent;