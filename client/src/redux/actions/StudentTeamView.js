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