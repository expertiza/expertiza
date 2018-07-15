import * as ActionTypes from './ActionTypes';
import { baseUrl } from '../shared/baseURL';
import axios from 'axios';

export const fetchProfile = () =>(dispatch) => {
    return axios({
        method: 'get',
        url: baseUrl + 'profile',
        headers: { AUTHORIZATION: "Bearer " + localStorage.getItem('jwt') }
    })
    .then(response => response.data)
    .then(profile => dispatch(addProfile(profile)))
    .catch(error => console.log(error));
}

export const fetchInstitutions = () =>(dispatch) => {
    return axios({
        method: 'get',
        url: baseUrl + 'institution',
        headers: { AUTHORIZATION: "Bearer " + localStorage.getItem('jwt') }
    })
    .then(response => response.data)
    .then(institutions => dispatch(addInstitutions(institutions)))
    .catch(error => console.log(error));
}

export const addProfile = (profile) => ({
    type: ActionTypes.ADD_PROFILE,
    payload: profile
});

export const profileFailed = (errormess) => ({
    type: ActionTypes.PROFILE_FAILED,
    payload: errormess
});

export const editProfile = (profile)  => (dispatch) => {

    const newprofile = 
    {
        user: profile
    };  
    return axios({
        method: 'put',
        url: baseUrl + 'profile/update', 
        body: JSON.stringify(newprofile), 
        headers: {
             "AUTHORIZATION": "Bearer " + "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyIjo2fQ.edz6wZkJeHqaZjBOtOLwO-9WSQIQo0RnQYBNl7AoTS0",
             "Content-Type": 'application/json'  
            }
    })
    .then(response => {
            if(response.ok){
                return response;
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
    .then(response => console.log(response.data))
    .then(profile => dispatch(addProfile(profile)))
    .catch(error => dispatch(profileFailed(error.message)));
}

export const addInstitutions = (institutions) => ({
    type: ActionTypes.ADD_INSTITUTIONS,
    payload: institutions
});

