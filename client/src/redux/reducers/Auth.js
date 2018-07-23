import * as actionType from '../index'
import {updateObject}  from '../../shared/utility/utility'

const initialize = {
    jwt: null,
    error: false,
    loggedIn: false,
    isPasswordresetSuccess: false,
    passwordResetEmailSent: false,
    usernameForget: false
}

const authReducer = (state = initialize, action) => {
    switch (action.type) {
        case actionType.FORGET_USERNAME:
            return updateObject(state, { usernameForget: true })
        case actionType.AUTH_SUCCESS:
            return updateObject(state, { error: false, jwt: action.jwt, loggedIn: true })
        case actionType.AUTH_FAILURE:
            return updateObject(state, { error: action.error, loggedIn: false })
        case actionType.AUTH_LOGOUT:
            return updateObject(state, {jwt: null, loggedIn: false})
        case actionType.PASSWORD_RESET_FAILURE:
            return updateObject(state, {isPasswordresetSuccess: false})
        case actionType.PASSWORD_RESET_SUCCESS:
            return updateObject(state, {isPasswordresetSuccess: true })
        case actionType.PASSWORD_RESET_EMAIL_SEND_SUCCESS:
            return updateObject(state, { passwordResetEmailSent: true })
        case actionType.PASSWORD_RESET_EMAIL_SEND_FAILURE:
            return updateObject(state, {passwordResetEmailSent: false })
        default:
            return state;
    }
}
export default authReducer;