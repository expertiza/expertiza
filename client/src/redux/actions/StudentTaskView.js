import axios from '../../axios-instance'
import * as actions from '../index'

export const onLoad = (id) => {
    return dispatch => {
        console.log('id in actions is :', id)
        axios({
            method: 'post',
            url: 'student_task/view',
            headers: { "Content-Type": "application/json",
                       AUTHORIZATION: "Bearer " + localStorage.getItem('jwt')},
            data: { "id": id }
        })
        .then(response => {
            console.log("data recieved is:", response.data)
            if(response.data.denied) {
                dispatch(actions.loadFailure())
            }else {
                console.log("need to see data here",response.data)
                dispatch(actions.loadSuccess(response.data));
                dispatch(actions.submission_allowed(response.data.assignment.id, response.data.topic_id))
                dispatch(actions.check_reviewable_topics(response.data.assignment.id))
                dispatch(actions.get_current_stage(response.data.assignment.id, response.data.topic_id))
                dispatch(actions.quiz_allowed(response.data.assignment.id, response.data.topic_id))   
                dispatch(actions.unsubmitted_self_review(response.data.participant.id))             
            }
        })
        .catch(error => {
                console.log(error)
        } )
    }
}


export const unsubmitted_self_review = (participant_id) => {
    return dispatch => {
        axios({
            method: 'post',
            url: 'student_task/unsubmitted_self_review',
            headers: { "Content-Type": "application/json", AUTHORIZATION: "Bearer " + localStorage.getItem('jwt')},
            data: { "participant_id": participant_id }
        })
        .then( res => dispatch(actions.unsubmitted_self_review_success(res.data.unsubmitted_self_review)))
        .catch( e => console.log(e))
    }
}

export const unsubmitted_self_review_success = (quiz_allowed) => {
    return {
        type: actions.STUDENT_TASK_VIEW_UNSUBMITTED_SELF_REVIEW,
        quiz_allowed: quiz_allowed
    }
}

export const quiz_allowed = (assignment_id, topic_id) => {
    return dispatch => {
        axios({
            method: 'post',
            url: 'student_task/quiz_allowed',
            headers: { "Content-Type": "application/json", AUTHORIZATION: "Bearer " + localStorage.getItem('jwt')},
            data: { "assignment_id": assignment_id, topic_id: topic_id  }
        })
        .then( res => dispatch(actions.quiz_allowed_success(res.data.quiz_allowed)))
        .catch( e => console.log(e))
    }
}

export const quiz_allowed_success = (quiz_allowed) => {
    return {
        type: actions.STUDENT_TASK_VIEW_QUIZ_ALLOWED,
        quiz_allowed: quiz_allowed
    }
}
export const get_current_stage = (assignment_id, topic_id) => {
    return dispatch => {
        axios({
            method: 'post',
            url: 'student_task/get_current_stage',
            headers: { "Content-Type": "application/json", AUTHORIZATION: "Bearer " + localStorage.getItem('jwt')},
            data: { "assignment_id": assignment_id, topic_id: topic_id  }
        })
        .then( res => dispatch(actions.get_current_stage_success(res.data.check_reviewable_topics)))
        .catch( e => console.log(e))
    }
}

export const get_current_stage_success = (get_current_stage) => {
    return {
        type: actions.STUDENT_TASK_VIEW_GET_CURRENT_STAGE,
        get_current_stage: get_current_stage
    }
}
export const check_reviewable_topics = (assignment_id) => {
    return dispatch => {
        axios({
            method: 'post',
            url: 'student_task/check_reviewable_topic',
            headers: { "Content-Type": "application/json", AUTHORIZATION: "Bearer " + localStorage.getItem('jwt')},
            data: { "assignment_id": assignment_id  }
        })
        .then( res => dispatch(actions.check_reviewable_topics_success(res.data.check_reviewable_topics)))
        .catch( e => console.log(e))
    }
}



export const metareview_allowed = (assignment_id, topic_id) => {
    return dispatch => {
        axios({
            method: 'post',
            url: 'student_task/metareview_allowed',
            headers: { "Content-Type": "application/json", AUTHORIZATION: "Bearer " + localStorage.getItem('jwt')},
            data: { "assignment_id": assignment_id , "topic_id": topic_id }
        })
        .then( res => dispatch(actions.metareview_allowed_success(res.data.metareview_allowed)))
        .catch( e => console.log(e))
    }
}

export const metareview_allowed_success = (metareview_allowed) => {
    return {
        type: actions.STUDENT_TASK_VIEW_METAREVIEW_ALLOWED,
        metareview_allowed: metareview_allowed
    }
}

export const check_reviewable_topics_success = (check_reviewable_topics) => {
    return {
        type: actions.STUDENT_TASK_VIEW_CHECK_REVIEWABLE_TOPICS,
        check_reviewable_topics: check_reviewable_topics
    }
}

export const submission_allowed = (assignment_id, topic_id) => {
    return dispatch => {
        axios({
            method: 'post',
            url: 'student_task/submission_allowed',
            headers: { "Content-Type": "application/json",
                       AUTHORIZATION: "Bearer " + localStorage.getItem('jwt')},
            data: { "assignment_id": assignment_id ,
                    "topic_id": topic_id  }
        })
        .then( res => dispatch(actions.submission_allowed_success(res.data.sub_allowed)))
        .catch( e => console.log(e))
    }
}

export const submission_allowed_success = (submissions_allowed) => {
    return {
        type: actions.STUDENT_TASK_VIEW_SUBMISSION_ALLOWED,
        submissions_allowed: submission_allowed
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