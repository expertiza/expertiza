import  * as actions from '..ActionTypes'
import axios from 'axios'


export const authStart = () => {
    return {
        type: actions.AUTH_START
    }
}
export const authSuccess = (idToken, localId) => {
    return {
        type: actions.AUTH_SUCCESS,
        idToken : idToken,
        localId: localId,
    }
}
export const authFailure = (error) => {
    return {
        type: actions.AUTH_FAILURE,
        error: error
    }
}

// export const logOut = () => {
//     localStorage.removeItem('token')
//     localStorage.removeItem('userId')
//     localStorage.removeItem('expirationDate')
//     return {
//         type: actions.AUTH_LOGOUT
//     }
// }



export const auth = (email, password,isSignUp) => {
    return dispatch => {
        dispatch(authStart());
        console.log(email, password, isSignUp)
        const payload = { email: email, password: password, returnSecureToken : true}
        let url = 'https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=AIzaSyDDSbfGxvn7zMJ4JScdzJXbxaXpq2cbrp4'
        if(!isSignUp)
            url = 'https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=AIzaSyDDSbfGxvn7zMJ4JScdzJXbxaXpq2cbrp4'
        axios.post(url, payload)
        .then(response => { 
            // console.log(response)
            localStorage.setItem('token', response.data.idToken)
            localStorage.setItem('expirationDate', new Date(new Date().getTime()+ response.data.expiresIn *1000))
            localStorage.setItem('userId', response.data.localId)
            dispatch(authSuccess(response.data.idToken, response.data.localId))
            console.log('fa1'+response.data.expiresIn)
            dispatch(checkAuthTimeout(response.data.expiresIn))
        })
        .catch(error => {
            // console.log(error)
            dispatch(authFailure(error.response.data.error))
        })
    }
    
}



export const checkAuthTimeout = (expirationTime) => {
    return dispatch => {
        setTimeout( () => dispatch(logOut()) ,expirationTime * 1000 )
    }
}


export const authStateCheck = () => {
    return dispatch => {
        const token = localStorage.getItem('token')
        // console.log(token)
        if(!token){
            dispatch(logOut())
        }else{
            const expirationDate = new Date(localStorage.getItem('expirationDate'))
            if(expirationDate <= new Date()){
                dispatch(logOut())
            }else{
                const userId = localStorage.getItem('userId')
                dispatch(authSuccess(token, userId))
                dispatch(checkAuthTimeout( ( expirationDate.getTime() - new Date().getTime() )  /1000))
            }
        }

    }
}