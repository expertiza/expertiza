import axios from '../../axios-instance'
import * as actions from '../index'

export const fetchAssignmentReviewData = (id) => (dispatch) =>{
    return axios ({
        method : 'get',
        url : 'student_review/list?id='+id,
        headers: { 
                    AUTHORIZATION: "Bearer " + localStorage.getItem('jwt')
                 }
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

// export const addReviewList = (data) => ({
//     type: actions.ADD_NEW_REVIEW_TOPIC,
//     payload: data
// });

export const reviewNewTopic = (assignment_id, user_id, topic_id) => {
    var headers = {
        'Content-Type': 'application/json',
        'Authorization': "Bearer " + localStorage.getItem('jwt') 
    }
    return axios ({
        method: 'post',
        url: 'review_mapping/assign_reviewer_dynamically',
        data: {
            assignment_id: assignment_id,
            reviewer_id:user_id,
            topic_id: topic_id
        },
        headers
    })
    .then(response => {
             console.log(response.data.server_msg);
    })
    .catch(error => console.log(error));
}
