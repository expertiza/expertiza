import * as ActionTypes from './ActionTypes';
import { baseUrl } from '../shared/baseURL';
import axios from 'axios';

export const fetchProfile = () =>(dispatch) => {
    return axios({
        method: 'get',
        url: baseUrl + 'profile',
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
        url: baseUrl + 'institution',
        headers: { AUTHORIZATION: "Bearer " + localStorage.getItem('jwt') }
    })
    .then(response => response.data)
    .then(institutions => dispatch(addInstitutions(institutions)))
    .catch(error => console.log(error));
}

export const fetchStudentsTeamedWith = () =>(dispatch) => {
    return axios ({
        method : 'get',
        url : baseUrl + 'student_task/list',
        headers: { AUTHORIZATION: "Bearer " + localStorage.getItem('jwt') }
    })
    .then(response =>{ console.log('hereeeeeeeeeee',response.data) 
        dispatch(addStudentsTeamedWith(response.data.studentsTeamedWith[""]))
    } )
    .catch(error => console.log('eeeeeee',error));

}

export const fetchStudentTasks = () =>(dispatch) => {
    return axios({
        method: 'get',
        url: baseUrl + 'student_task/list',
        headers: { AUTHORIZATION: "Bearer " + localStorage.getItem('jwt') }
    })
    .then(response => response.data)
    .then(studentTasks => dispatch(addStudentTasks(studentTasks)))
    .catch(error => console.log(error));
}

export const changeHandle = (handle_name) => {
    return {
        type: ActionTypes.CHANGE_HANDLE,
        handle: handle_name
    }
}

export const addProfile = (profile) => ({
    type: ActionTypes.ADD_PROFILE,
    payload: profile
});

export const edit_profile = (profile) => ({
    type: ActionTypes.EDIT_PROFILE,
    payload: profile
});

export const profileFailed = (errormess) => ({
    type: ActionTypes.PROFILE_FAILED,
    payload: errormess
});

export const addStudentsTeamedWith = (studentsTeamedWith) => ({
    type: ActionTypes.ADD_STUDENTSTEAMEDWITH,
    payload: studentsTeamedWith
});

export const addStudentTasks = (studentTasks) => ({
    type: ActionTypes.ADD_STUDENTTASKS,
    payload: studentTasks
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
        url: baseUrl + 'profile/update', 
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
    type: ActionTypes.ADD_INSTITUTIONS,
    payload: institutions
});

