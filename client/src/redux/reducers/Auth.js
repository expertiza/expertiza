import * as actionType from '../actions/index'
import {updateObject}  from './utility'

const initialize = {
    idToken: null,
    userId: null,
    error: false,
    loading: false,
}

const authReducer = (state = initialize, action) => {
    switch (action.type) {
        case actionType.AUTH_START:
            return updateObject(state, {loading: true })
        case actionType.AUTH_SUCCESS:
            return updateObject(state, {loading: false, error: false, userId: action.localId, idToken: action.idToken })
        case actionType.AUTH_FAILURE:
            return updateObject(state, {loading: false, error: action.error })
        case actionType.AUTH_LOGOUT:
            return updateObject(state, {idToken: null, userId: null})
        
        default:
            return state;
    }
}
export default authReducer;