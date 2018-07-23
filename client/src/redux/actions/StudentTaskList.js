import axios from '../../axios-instance'
import * as actions from '../index'

export const fetchStudentsTeamedWith = () =>(dispatch) => {
    return axios ({
        method : 'get',
        url : 'student_task/list',
        headers: { AUTHORIZATION: "Bearer " + localStorage.getItem('jwt') }
    })
    .then(response =>{ 
        dispatch(actions.addStudentsTeamedWith(response.data.studentsTeamedWith[""]))
    } )
    .catch(error => console.log(error));

}

export const fetchStudentTasks = () =>(dispatch) => {
    return axios({
        method: 'get',
        url: 'student_task/list',
        headers: { AUTHORIZATION: "Bearer " + localStorage.getItem('jwt') }
    })
    .then(response => response.data)
    .then(studentTasks => dispatch(actions.addStudentTasks(studentTasks)))
    .catch(error => console.log(error));
}




export const addStudentsTeamedWith = (studentsTeamedWith) => ({
    type: actions.ADD_STUDENTSTEAMEDWITH,
    payload: studentsTeamedWith
});

export const addStudentTasks = (studentTasks) => ({
    type: actions.ADD_STUDENTTASKS,
    payload: studentTasks
});

