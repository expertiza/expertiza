import axios from '../../axios-instance'
import * as actions from '../index'

export const fetchStudentsTeamView = (student_id) => (dispatch) => {
    return axios({
            method: 'post',
            url: 'student_teams/view',
            headers: {
                AUTHORIZATION: "Bearer " + localStorage.getItem('jwt')
            },
            data: {
                "student_id": student_id
            }
        })
        .then(response => {
            dispatch(actions.fetchStudentsTeamViewSuccess(response.data))
            if(response.data.team) {
                dispatch(actions.getAdContent(response.data.team.id))
            }
        })
        .catch(error => console.log(error));

}

export const fetchStudentsTeamViewSuccess = (studentsTeamView) => ({
    type: actions.STUDENTS_TEAM_VIEW_SUCCESS,
    payload: studentsTeamView
});

export const updateTeamName = (student_id, team_name) => (dispatch) => {
    return axios({
            method: 'post',
            url: 'student_teams',
            headers: {
                AUTHORIZATION: "Bearer " + localStorage.getItem('jwt')
            },
            data: {
                "team": {
                    "name": team_name
                },
                "student_id": student_id
            }
        })
        .then(response => console.log(response.data))
        .catch(error => console.log(error));
}

export const remove_participant_student_teams = (student_id, team_id) => dispatch => {
    return axios({
        method: 'post',
        url: 'student_teams/remove_participant',
        headers: {
            AUTHORIZATION: "Bearer " + localStorage.getItem('jwt')
        },
        data: {
            "team_id" : team_id,
            "student_id": student_id
        }
    })
    .then(response => {console.log(response.data)
                        dispatch(actions.fetchStudentsTeamView(student_id))}
)
    .catch(error => console.log(error)); 
}

{/* {:controller => 'invitations', :action => 'cancel', :inv_id => inv.id, :student_id => @student.id} */}
export const retractInvitation = (inv_id, student_id) => dispatch => {
    return axios({
        method: 'post',
        url: 'invitations/cancel',
        headers: {
            AUTHORIZATION: "Bearer " + localStorage.getItem('jwt')
        },
        data: {
            "inv_id" : inv_id,
            "student_id": student_id
        }
    })
    .then(response => {console.log(response.data)
                        dispatch(actions.fetchStudentsTeamView(student_id))}
)
    .catch(error => console.log(error)); 
}

export const invitePeopleToAssignment = (team_id, student_id, assignment_id, user_name) => dispatch => {
    return axios({
        method: 'post',
        url: 'invitations',
        headers: {
            AUTHORIZATION: "Bearer " + localStorage.getItem('jwt')
        },
        data: {
            "team_id" : team_id,
            "student_id": student_id,
            "assignment_id" : assignment_id,
            "user" : { "name": user_name}
        }
    })
    .then(response => {
                    if(response.data.error) {
                        dispatch(setAlert(response.data.error))
                        
                    } else {
                        dispatch(setAlert("invitation sent successfully"))
                    }
                    }
)
    .catch(error => console.log(error)); 
}

export const setAlert = (alert) => {
    console.log('in set alert')
    return {
        type: actions.SET_ALERT_AFTER_INV_SENT,
        alert: alert
    }
}

export const acceptInvitationToAssignment = (inv_id, team_id, student_id) => dispatch => {
    return axios({
        method: 'post',
        url: 'invitations/accept',
        headers: {
            AUTHORIZATION: "Bearer " + localStorage.getItem('jwt')
        },
        data: {
            "inv_id" : inv_id,
            "team_id" : team_id,
            "student_id": student_id,
        }
    })
    .then(response => {console.log(response.data)
                    if(response.data.error) {
                        dispatch(setAlert(response.data.error))
                    } else {
                        dispatch(setAlert("invitation accepted successfully"))
                    }
                }
        )
    .catch(error => console.log(error)); 
}

export const declineInvitationToAssignment = (inv_id, student_id) => dispatch => {
    return axios({
        method: 'post',
        url: 'invitations/decline',
        headers: {
            AUTHORIZATION: "Bearer " + localStorage.getItem('jwt')
        },
        data: {
            "inv_id" : inv_id,
            "student_id": student_id,
        }
    })
    .then(response => {console.log(response.data)
                    if(response.data.error) {
                        dispatch(setAlert(response.data.error))
                    } else {
                        dispatch(setAlert("invitation accepted successfully"))
                    }
                }
        )
    .catch(error => console.log(error)); 
}

export const getAdContent = ( team_id) => dispatch => {
    return axios({
        method: 'post',
        url: 'advertise_for_partner/getAdContent',
        headers: {
            AUTHORIZATION: "Bearer " + localStorage.getItem('jwt')
        },
        data: {
            "team_id" : team_id
        }
    })
    .then(response => dispatch(actions.AdContentSuccess(response.data.ad_content )) )
    .catch(error => console.log(error)); 
    }
 
    export const AdContentSuccess = (ad_content) => {
        return  {
            type: actions.ADVERTISE_CONTENT_SUCCESS,
            ad_content: ad_content
        }
    }

    export const updateCommentForAdvertisement = (team_id, comments_for_advertisement) =>dispatch => {
        return axios({
            method: 'post',
            url: `advertise_for_partner/${team_id}`,
            headers: {
                AUTHORIZATION: "Bearer " + localStorage.getItem('jwt')
            },
            data: {
                "comments_for_advertisement" : comments_for_advertisement
            }
        })
        .then(response => { 
                            if(response.data.message ) {
                                dispatch(actions.updateCommentSuccess(response.data.message)) 
                            } else {
                                dispatch(actions.updateCommentFailure(response.data.error))
                            }
                        }
             ) 
    }

    export const updateCommentSuccess = (message) => {
        return {
            type: actions.UPDATE_COMMENT_SUCCESS,
            message: message 
        }
    }

    export const updateCommentFailure = (error) => {
        return {
            type: actions.UPDATE_COMMENT_FAILURE,
            error: error 
        }
    }