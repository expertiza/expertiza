import * as actionType from '../index'
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
    timeline_list: null
}

const studentTaskViewReducer = (state = initialize, action) => {
    switch (action.type) {
        case actionType.STUDENT_TASK_VIEW_SUCCESS:
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
        case actionType.STUDENT_TASK_VIEW_FAILURE:
            return updateObject(state , {denied: true})
        
        default:
            return state;
    }
}
export default studentTaskViewReducer;