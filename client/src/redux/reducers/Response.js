import * as actions from '../index'
import {updateObject}  from '../../shared/utility/utility'

const initialize = {
    map: null,
    survey: false,
    survey_parent: null,
    title: null,
    assignment: null,
    loading: true
}

const responseReducer = (state = initialize, action) => {
    switch (action.type) {
        case actions.FETCH_REVIEW_DATA_SUCCESS:
            return updateObject(state, {                                     
                                            title: action.payload.title,
                                            assignment: action.payload.assignment,
                                            ans: action.payload.ans,
                                            questions: action.payload.questions,
                                            response: action.payload.response,
                                            contributor: action.payload.contributor,
                                            author_questions: action.payload.author_questions,
                                            author_answers: action.payload.author_answers,
                                            author_response_map: action.payload.author_response_map,
                                            loading: false })
        case actions.FETCH_REVIEW_DATA_FAILURE:
            return updateObject(state, { laoding: true })  

        case actions.FETCH_EDIT_DATA_SUCCESS:
                return updateObject(state, {
                                            review_scores: action.payload.review_scores,
                                            questions: action.payload.questions,
                                            questionnaire: action.payload.questionnaire,
                                            assignment: action.payload.assignment,
                                            loading: false

                })
        default:
            return state;
    }
}
export default responseReducer;