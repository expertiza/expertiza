import axios from '../../axios-instance'
import * as actions from '../index'
import { onLoad } from '../actions/StudentTaskView';

export const SubmitURL = (id, submission) => (dispatch) => {
    console.log("loda");
    return axios ({
        method : 'post',
        url : 'submitted_content/submit_hyperlink?='+id,
        headers: { AUTHORIZATION: "Bearer " + localStorage.getItem('jwt') },
        data: {"id": id, "submission" : submission, "upload_link": "Upload link" }
    })
    .then(console.log(submission))
    .then(response => dispatch(onLoad(id)))
    .catch(error => console.log(error));
}