import * as actions from '../index';
import axios from '../../axios-instance';

export const fetchProfile = () =>(dispatch) => {
    return axios({
        method: 'get',
        url: 'profile',
        headers: { AUTHORIZATION: "Bearer " + localStorage.getItem('jwt') }
    })
    .then(response => { return {response: response.data, servermsg : response.status} } )
    .then(profile => dispatch(addProfile(profile)))
    .catch(error => console.log(error));
}

export const fetchInstitutions = () =>(dispatch) => {
    console.log('in fetchInstitutions')
    return axios({
        method: 'get',
        url: 'institution',
        headers: { AUTHORIZATION: "Bearer " + localStorage.getItem('jwt') }
    })
    .then(response => response.data)
    .then(institutions => dispatch(addInstitutions(institutions)))
    .catch(error => console.log(error));
}

export const changeHandle = (handle_name) => {
    return {
        type: actions.CHANGE_HANDLE,
        handle: handle_name
    }
}

export const addProfile = (profile) => ({
    type: actions.ADD_PROFILE,
    payload: profile
});

export const edit_profile = (profile) => ({
    type: actions.EDIT_PROFILE,
    payload: profile
});

export const profileFailed = (errormess) => ({
    type: actions.PROFILE_FAILED,
    payload: errormess
});

export const editProfile = (profile,aq)  => (dispatch) => {
    const newprofile = 
    {
        user: profile,
        assignment_questionnaire: aq
    };
    var headers = {
        'Content-Type': 'application/json',
        'Authorization': "Bearer " + localStorage.getItem('jwt') 
    }
    return axios({
        method: 'put',
        url: 'profile/update', 
        data: JSON.stringify(newprofile), 
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
    .then(profile => dispatch(edit_profile(profile)))
    .catch(error => console.log(error));
}

export const addInstitutions = (institutions) => ({
    type: actions.ADD_INSTITUTIONS,
    payload: institutions
});

