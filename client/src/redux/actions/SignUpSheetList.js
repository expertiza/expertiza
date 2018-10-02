import axios from '../../axios-instance'
import * as actions from '../index'

export const onSignUpSheetLoad = (id,flag) => {

    return dispatch => {
        console.log('id in actions is :', id)
        console.log('flag', flag)
        axios({
            method: 'post',
            url: 'sign_up_sheet/list',
            headers: { "Content-Type": "application/json",
                       AUTHORIZATION: "Bearer " + localStorage.getItem('jwt')},
            data: { "id": id }
        })
        .then(response => dispatch(actions.addSignUpSheetList(response.data, flag)))
        .catch(error => {
                console.log(error)
        } )
    }
}

export const onSignUp = (id, topic_id, assignment_id) => {
    return dispatch => {
        console.log('id in actions is :', id, topic_id, assignment_id)
        axios({
            method: 'get',
            url: 'sign_up_sheet/sign_up',
            headers: { "Content-Type": "application/json",
                       AUTHORIZATION: "Bearer " + localStorage.getItem('jwt')},
            params: { "id": id, "topic_id": topic_id, "assignment_id": assignment_id }
        })
        .then(response => dispatch(actions.addSignUp(response.data)))
        .catch(error => {
                console.log(error)
        } )
    }
}

export const onDelete = (id, topic_id, assignment_id) => {
    return dispatch => {
        console.log('id in actions is :', id, topic_id, assignment_id)
        axios({
            method: 'get',
            url: 'sign_up_sheet/delete_signup',
            headers: { "Content-Type": "application/json",
                       AUTHORIZATION: "Bearer " + localStorage.getItem('jwt')},
            params: { "id": id, "topic_id": topic_id, "assignment_id": assignment_id }
        })
        .then(response => dispatch(actions.addDelete(response.data)))
        .catch(error => {
                console.log(error)
        } )
    }
}


export const addSignUpSheetList = (signupsheetlist, flag) => ({
    type: actions.ADD_SIGNUPSHEETLIST,
    flag: flag,
    payload: signupsheetlist
});

export const addSignUp = (signupmsg) => ({
    type: actions.ADD_SIGNUP,
    payload: signupmsg
});

export const addDelete = (deletemsg) => ({
    type: actions.ADD_DELETE,
    payload: deletemsg
});