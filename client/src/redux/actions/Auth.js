import  * as actions from '../index'
import axios from 'axios'


export const authSuccess = (jwt) => {
    console.log('in auth success action')
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
        if(!localStorage.getItem('jwt')) {
            axios({
                method: 'post',
                url: 'http://localhost:3001/api/v1/sessions',
                headers: { "Content-Type": "application/json"},
                data: {auth: { name: name, password: password }}
            })
            .then(response => {
                console.log(response)
                localStorage.setItem('jwt', response.data.jwt)
                dispatch(authSuccess(response.data.jwt))
            })
            .catch(error => {
                            console.log(error)
                            alert('Invalid username or password')
                            dispatch(actions.authFailure(error))
                            } )
        }else {
            console.log('jwt exists allready')
            dispatch(authSuccess(localStorage.getItem('jwt')))
        }
    }
}