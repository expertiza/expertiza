import * as actions from '../index'
import {updateObject}  from '../../shared/utility/utility'

const initialize = {
    loaded: false,
    participant: null,
    can_submit : null,
    can_review: null,
    can_take_quiz: null,
    authorization: null,
    team : null,
    denied: false,
    assignment: null,
    can_provide_suggestions: null,
    topic_id: null,
    topics: null,
    timeline_list: null,
    submission_allowed: false,
    check_reviewable_topics: false,
    metareview_allowed: false,
    get_current_stage: '',
    quiz_allowed: false,
    unsubmitted_self_review: false
}

const studentTaskViewReducer = (state = initialize, action) => {
    switch (action.type) {
        case actions.STUDENT_TASK_VIEW_SUCCESS:
            return updateObject(state, { participant: action.participant,
                                        can_submit : action.can_submit,
                                        can_review: action.can_review,
                                        can_take_quiz: action.can_take_quiz,
                                        authorization: action.authorization,
                                        team : action.team,
                                        assignment: action.assignment,
                                        can_provide_suggestions: action.can_provide_suggestions,
                                        topic_id: action.topic_id,
                                        topics: action.topics,
                                        timeline_list: action.timeline_list,
                                        loaded: true })
        case actions.STUDENT_TASK_VIEW_FAILURE:
            return updateObject(state, {denied: true})
        case actions.STUDENT_TASK_VIEW_SUBMISSION_ALLOWED:
            return updateObject(state, { submission_allowed: action.submission_allowed })
        case actions.STUDENT_TASK_VIEW_CHECK_REVIEWABLE_TOPICS:
            return updateObject(state, {check_reviewable_topics: action.check_reviewable_topics})
        case actions.STUDENT_TASK_VIEW_METAREVIEW_ALLOWED:
            return updateObject(state, { metareview_allowed: action.metareview_allowed })
        case actions.STUDENT_TASK_VIEW_GET_CURRENT_STAGE:
            return updateObject(state, {get_current_stage: action.get_current_stage})
        case actions.STUDENT_TASK_VIEW_QUIZ_ALLOWED:
            return updateObject(state, {quiz_allowed: action.quiz_allowed})
        case actions.STUDENT_TASK_VIEW_UNSUBMITTED_SELF_REVIEW:
            return updateObject(state, {unsubmitted_self_review: action.unsubmitted_self_review})
        default:
            return state;
    }
}
export default studentTaskViewReducer;