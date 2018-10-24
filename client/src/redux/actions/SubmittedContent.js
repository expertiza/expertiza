import axios from '../../axios-instance'
import * as actions from '../index'

export const onSubmittedContentLoad = (id) => {

    return dispatch => {
        console.log('id in actions is :', id)
        axios({
            method: 'get',
            url: 'submitted_content/'+id+'/edit',
            headers: { "Content-Type": "application/json",
                       AUTHORIZATION: "Bearer " + localStorage.getItem('jwt')},
            data: { "id": id }
        })
        .then(response => dispatch(actions.getSumittedContent(response.data)))
        .catch(error => {
                console.log(error)
        } )
    }
}

// export const onSignUp = (id, topic_id, assignment_id) => {
//     return dispatch => {
//         console.log('id in actions is :', id, topic_id, assignment_id)
//         axios({
//             method: 'get',
//             url: 'sign_up_sheet/sign_up',
//             headers: { "Content-Type": "application/json",
//                        AUTHORIZATION: "Bearer " + localStorage.getItem('jwt')},
//             params: { "id": id, "topic_id": topic_id, "assignment_id": assignment_id }
//         })
//         .then(response => dispatch(actions.addSignUp(response.data)))
//         .catch(error => {
//                 console.log(error)
//         } )
//     }
// }

// export const onDelete = (id, topic_id, assignment_id) => {
//     return dispatch => {
//         console.log('id in actions is :', id, topic_id, assignment_id)
//         axios({
//             method: 'get',
//             url: 'sign_up_sheet/delete_signup',
//             headers: { "Content-Type": "application/json",
//                        AUTHORIZATION: "Bearer " + localStorage.getItem('jwt')},
//             params: { "id": id, "topic_id": topic_id, "assignment_id": assignment_id }
//         })
//         .then(response => dispatch(actions.addDelete(response.data)))
//         .catch(error => {
//                 console.log(error)
//         } )
//     }
// }


export const getSumittedContent = (submittedContent) => ({
    type: actions.ADD_SUBMITTEDCONTENT,
    payload: submittedContent
});

// export const addSignUp = (signupmsg) => ({
//     type: actions.ADD_SIGNUP,
//     payload: signupmsg
// });

// export const addDelete = (deletemsg) => ({
//     type: actions.ADD_DELETE,
//     payload: deletemsg
// });