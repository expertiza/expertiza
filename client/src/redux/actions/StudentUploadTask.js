import axios from '../../axios-instance'
import * as actions from '../index'
import { onLoad } from '../actions/StudentTaskView';

export const SubmitURL = (id, submission) => (dispatch) => {
    return axios ({
        method : 'post',
        url : 'submitted_content/submit_hyperlink',
        headers: { AUTHORIZATION: "Bearer " + localStorage.getItem('jwt') },
        data: {"id": id, "submission" : submission, "upload_link": "Upload link" }
    })
    .then(console.log(submission))
    .then(response => dispatch(onLoad(id)))
    .catch(error => console.log(error));
}

export const DeleteURL = (id, chk_links) => (dispatch) => {
    return axios ({
        method : 'post',
        url : 'submitted_content/remove_hyperlink',
        headers: { AUTHORIZATION: "Bearer " + localStorage.getItem('jwt') },
        data: {"id": id, "chk_links" : chk_links}
    })
    .then(response => dispatch(onLoad(id)))
    .catch(error => console.log(error));
}