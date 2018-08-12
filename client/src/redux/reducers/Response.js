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
            return updateObject(state, {    map: action.payload.map, 
                                            survey: action.payload.survey, 
                                            survey_parent: action.payload.survey_parent, 
                                            title: action.payload.title,
                                            assignment: action.payload.assignment,
                                            loading: false })
        case actions.FETCH_REVIEW_DATA_FAILURE:
            return updateObject(state, { laoding: true })  
        default:
            return state;
    }
}
export default responseReducer;