import * as actions from '../index'
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
        case actions.FORGET_USERNAME:
            return updateObject(state, { usernameForget: true })
        case actions.AUTH_SUCCESS:
            return updateObject(state, { error: false, jwt: action.jwt, loggedIn: true })
        case actions.AUTH_FAILURE:
            return updateObject(state, { error: action.error, loggedIn: false })
        case actions.AUTH_LOGOUT:
            return updateObject(state, {jwt: null, loggedIn: false})
        case actions.PASSWORD_RESET_FAILURE:
            return updateObject(state, {isPasswordresetSuccess: false})
        case actions.PASSWORD_RESET_SUCCESS:
            return updateObject(state, {isPasswordresetSuccess: true })
        case actions.PASSWORD_RESET_EMAIL_SEND_SUCCESS:
            return updateObject(state, { passwordResetEmailSent: true })
        case actions.PASSWORD_RESET_EMAIL_SEND_FAILURE:
            return updateObject(state, {passwordResetEmailSent: false })
        default:
            return state;
    }
}
export default authReducer;