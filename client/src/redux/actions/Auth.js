import  * as actions from '../index'
import axios from '../../axios-instance';

export const forgetUsername = () => {
    return {
        type: actions.FORGET_USERNAME
    }
}



export const forgetPasswordUpdate = (email, password, repassword, token) => {
    // console.log(email, password, repassword, token)
    return dispatch => {
        axios({
            method: 'post',
            url: 'password_retrieval/forgottenPasswordUpdatePassword',
            headers: { "Content-Type": "application/json"},
            data:{ "token": token, "reset": { "email": email, "password": password, "repassword": repassword }}
        })
        .then(response => {
            console.log(response)
            // alert('A password reset link has been sent to the address on file for this account.')
            dispatch(actions.passwordResetSuccess())
        })
        .catch(error => {
                console.log(error)
                alert('password reset failed')
                dispatch(actions.passwordResetFailure())
               } )
    }
}

export const passwordResetSuccess = () => {
    return {
        type: actions.PASSWORD_RESET_SUCCESS
    }
}

export const passwordResetFailure = () => {
    return {
        type: actions.PASSWORD_RESET_FAILURE
    }
}

export const passwordResetEmailSend = (email, username) => {
    return dispatch => {
        console.log('props recieved are:', email, username)
        axios({
            method: 'post',
            url: 'password_retrieval/forgottenPasswordSendLink',
            headers: { "Content-Type": "application/json"},
            data: { "user": { "email" : email, "username": username} }
        })
        .then(response => {
            console.log(response)
            alert('password reset successful')
            dispatch(actions.forgetPasswordSendSuccess())
        })
        .catch(error => {
                        console.log(error)
                        alert('Something went wrong. adding the log: ', error)
                        dispatch(actions.forgetPasswordSendFailure())
                        } )
    }
} 

export const forgetPasswordSendSuccess = () => {
    return {
        type: actions.PASSWORD_RESET_EMAIL_SEND_SUCCESS,
    }
}
export const forgetPasswordSendFailure = () => {
    return {
        type: actions.PASSWORD_RESET_EMAIL_SEND_FAILURE,
    }
}


export const authSuccess = (jwt) => {
    return {
        type: actions.AUTH_SUCCESS,
        jwt : jwt,
    }
}
export const authFailure = (error) => {
    return {
        type: actions.AUTH_FAILURE,
        error: error
    }
}

export const logOut = () => {
    localStorage.removeItem('jwt')
    return {
        type: actions.AUTH_LOGOUT
    }
}

export const auth = (name, password) => {
    return dispatch => {
        if( !localStorage.getItem('jwt') || (localStorage.getItem('jwt') && 
                localStorage.getItem('jwt_exp') <= (Date.now()/60) ) ) {
            axios({
                method: 'post',
                url: 'sessions',
                headers: { "Content-Type": "application/json"},
                data: {auth: { name: name, password: password }}
            })
            .then(response => {
                localStorage.setItem('jwt', response.data.jwt)
                localStorage.setItem('jwt_exp',(Date.now()/60) + 60*60*24*7)

                dispatch(authSuccess(response.data.jwt))
                dispatch(actions.fetchProfile())
                dispatch(actions.fetchInstitutions())
                dispatch(actions.fetchStudentsTeamedWith())
                dispatch(actions.fetchStudentTasks())
                dispatch(actions.fetchTeamCourse())
                dispatch(actions.fetchTasks())
                dispatch(actions.fetchRevisions())
                dispatch(actions.containsTopics())
                dispatch(actions.containsBadges())
            })
            .catch(error => {
                            console.log(error)
                            alert('Invalid username or password')
                            dispatch(actions.authFailure(error))
                            } )
        }else {
            console.log('jwt exists allready')
            dispatch(authSuccess(localStorage.getItem('jwt')))
            dispatch(actions.fetchProfile())
            dispatch(actions.fetchInstitutions())
            dispatch(actions.fetchStudentsTeamedWith())
            dispatch(actions.fetchStudentTasks())
            dispatch(actions.fetchTeamCourse())
            dispatch(actions.fetchTasks())
            dispatch(actions.fetchRevisions())
            dispatch(actions.containsTopics())
            dispatch(actions.containsBadges())
        }
    }
}

export const checkForAutoLogIn = () =>  {
    return dispatch => {
        if(localStorage.getItem('jwt') && localStorage.getItem('jwt_exp') > Date.now()/60 ) {
            console.log( 'auto login', localStorage.getItem('jwt_exp'),  Date.now()/60 )
            dispatch(authSuccess(localStorage.getItem('jwt')))
            dispatch(actions.fetchProfile())
            dispatch(actions.fetchInstitutions())
            dispatch(actions.fetchStudentsTeamedWith())
            dispatch(actions.fetchStudentTasks())
            dispatch(actions.fetchTeamCourse())
            dispatch(actions.fetchTasks())
            dispatch(actions.fetchRevisions())
            dispatch(actions.containsTopics())
            dispatch(actions.containsBadges())
        }
    }
}