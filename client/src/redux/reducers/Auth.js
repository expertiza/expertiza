import * as actionType from '../index'
import {updateObject}  from '../../shared/utility/utility'

const initialize = {
    jwt: null,
    error: false,
    loggedIn: false
}

const authReducer = (state = initialize, action) => {
    switch (action.type) {
        case actionType.AUTH_SUCCESS:{
            return updateObject(state, { error: false, jwt: action.jwt, loggedIn: true })
        }
        case actionType.AUTH_FAILURE:
            return updateObject(state, { error: action.error, loggedIn: false })
        case actionType.AUTH_LOGOUT:
            return updateObject(state, {jwt: null, loggedIn: false})
        
        default:
            return state;
    }
}
export default authReducer;