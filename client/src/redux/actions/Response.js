import  * as actions from '..'
import axios from '../../axios-instance';

export const fetchReviewData = (response_id) => {
    return dispatch => {
        axios({
            method: 'get',
            url: 'response/view',
            headers: { "Content-Type": "application/json",
                       AUTHORIZATION: "Bearer " + localStorage.getItem('jwt')},
            params:{ "id" : response_id }
        })
        .then(response => {
            dispatch(actions.fetchReviewDataSuccess(response.data))
        })
        .catch(error => {
                console.log(error)
                dispatch(actions.fetchReviewDataFailure())
               })
    }
}

export const fetchReviewDataSuccess = (payload) => {
    return {
        type: actions.FETCH_REVIEW_DATA_SUCCESS,
        payload: payload
    }
}

export const fetchEditData = (response_id) => {
    return dispatch => {
        axios({
            method: 'post',
            url: 'response/edit',
            headers: { "Content-Type": "application/json",
                       AUTHORIZATION: "Bearer " + localStorage.getItem('jwt')},
            data:{ "id" : response_id }
        })
        .then(response => {
            dispatch(actions.fetchEditDataSuccess(response.data))
        })
    }
}

export const fetchReviewDataFailure = () => {
    return {
        type: actions.FETCH_REVIEW_DATA_FAILURE
    }
}

export const fetchEditDataSuccess = (payload) => {
    return {
        type: actions.FETCH_EDIT_DATA_SUCCESS,
        payload: payload
    }
}