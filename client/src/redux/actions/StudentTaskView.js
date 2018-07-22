import axios from 'axios'
import * as actions from '../index'

export const onLoad = (id) => {
    return dispatch => {
        axios({
            method: 'post',
            url: 'http://localhost:3001/api/v1/student_task/view',
            headers: { "Content-Type": "application/json",
                       AUTHORIZATION: "Bearer " + localStorage.getItem('jwt')},
            data: { "id": 17 }
        })
        .then(response => {
            console.log("data recieved is:", response.data)
            if(response.data.denied) {
                dispatch(actions.loadFailure())
            }else {
                console.log(response.data)
                dispatch(actions.loadSuccess(response.data));
            }
        })
        .catch(error => {
                console.log(error)
        } )
    }
}

export const loadSuccess = (data) => {
    return {
        type: actions.STUDENT_TASK_VIEW_SUCCESS,
        participant: data.participant,
        can_submit : data.can_submit,
        can_review: data.can_review,
        can_take_quiz: data.can_take_quiz,
        authorization: data.authorization,
        team : data.team,
        assignment: data.assignment,
        can_provide_suggestions: data.can_provide_suggestions,
        topic_id: data.topic_id,
        topics: data.topics,
        timeline_list: data.timeline_list
    }
}

export const loadFailure = () => {
    return {
        type: actions.STUDENT_TASK_VIEW_FAILURE,
        denied: true
    }
}