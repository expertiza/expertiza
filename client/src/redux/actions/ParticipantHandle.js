import * as actions from '../index';
import axios from '../../axios-instance';
import {onLoad} from '../actions/StudentTaskView'

export const edit_handle = (participant) => {
    return {
        type: actions.PARTICIPANT_HANDLE_CHANGE,
        payload: participant
    }
}
export const editHandle = (participantid, newhand)  => (dispatch) => {
    const newparticipant = 
    {
        participant: {
            handle : newhand
        }        
    };
    var headers = {
        'Content-Type': 'application/json',
        'Authorization': "Bearer " + localStorage.getItem('jwt') 
    }
    return axios({
        method: 'put',
        url: 'participants/change_handle?id=' + participantid, 
        data: JSON.stringify(newparticipant), 
        headers
    })
    .then(response => {
            if(response.status === 200){
                return {response: response.data, servermsg: response.status};
            }
            else{
                var error = new Error('Error ' + response.status + ": " + response.statusText);
                error.reponse = response;
                throw error;
            }
    }, 
    error => {
        var errmess = new Error(error.message);
        throw errmess;
    })
    .then(handle => dispatch(onLoad(handle.response.participant.id)))
    .catch(error => console.log(error));
}