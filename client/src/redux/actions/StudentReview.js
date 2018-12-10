import axios from '../../axios-instance'
import * as actions from '../index'

export const fetchAssignmentReviewData = (id) => (dispatch) =>{
    return axios ({
        method : 'get',
        url : 'student_review/list?id='+id,
        headers: { AUTHORIZATION: "Bearer " + localStorage.getItem('jwt') }
    })
    .then(response => {
        dispatch(actions.addReviewList(response.data));
    })
    .catch(error => console.log(error));
}

export const addReviewList = (reviewData) => ({
    type: actions.ADD_ASSIGNMENT_REVIEW_DATA,
    payload: reviewData
});
