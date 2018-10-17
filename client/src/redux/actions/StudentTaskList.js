import axios from '../../axios-instance'
import * as actions from '../index'

export const fetchStudentsTeamedWith = () =>(dispatch) => {
    return axios ({
        method : 'get',
        url : 'student_task/list',
        headers: { AUTHORIZATION: "Bearer " + localStorage.getItem('jwt') }
    })
    .then(response => dispatch(actions.addStudentsTeamedWith(response.data.studentsTeamedWith)))
    .catch(error => console.log(error));

}

export const fetchStudentTasks = () =>(dispatch) => {
    return axios({
        method: 'get',
        url: 'student_task/list',
        headers: { AUTHORIZATION: "Bearer " + localStorage.getItem('jwt') }
    })
    // .then(response => console.log(response.data))
    .then(response => dispatch(actions.addStudentTasks(response.data.studentTasks)))
    .catch(error => console.log(error));
}

export const fetchTeamCourse = () =>(dispatch) => {
    return axios({
        method: 'get',
        url: 'student_task/list',
        headers: { AUTHORIZATION: "Bearer " + localStorage.getItem('jwt') }
    })
    .then(response => dispatch(actions.addTeamCourse(response.data.teamCourse)))
    .catch(error => console.log(error));
}

export const fetchTasks = () =>(dispatch) => {
    return axios({
        method: 'get',
        url: 'student_task/list',
        headers: { AUTHORIZATION: "Bearer " + localStorage.getItem('jwt') }
    })
    .then(response => dispatch(actions.addTasks(response.data.tasks_not_started)))
    .catch(error => console.log(error));
}

export const fetchRevisions = () =>(dispatch) => {
    return axios({
        method: 'get',
        url: 'student_task/list',
        headers: { AUTHORIZATION: "Bearer " + localStorage.getItem('jwt') }
    })
    .then(response => dispatch(actions.addTaskRevisions(response.data.taskrevisions)))
    .catch(error => console.log(error));
}

export const containsTopics = () =>(dispatch) => {
    return axios({
        method: 'get',
        url: 'student_task/list',
        headers: { AUTHORIZATION: "Bearer " + localStorage.getItem('jwt') }
    })
    .then(response => dispatch(actions.hasTopics(response.data.containsTopics)))
    .catch(error => console.log(error));
}

export const containsBadges = () =>(dispatch) => {
    return axios({
        method: 'get',
        url: 'student_task/list',
        headers: { AUTHORIZATION: "Bearer " + localStorage.getItem('jwt') }
    })
    .then(response => dispatch(actions.hasBadges(response.data.containsBadges)))
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

export const addTeamCourse = (teamCourse) => ({
    type: actions.ADD_TEAMCOURSE,
    payload: teamCourse
});

export const addTasks = (tasks_not_started) => ({
    type: actions.ADD_TASKS,
    payload: tasks_not_started
});

export const addTaskRevisions = (taskrevisions) => ({
    type: actions.ADD_TASKREVISIONS,
    payload: taskrevisions
});

export const hasTopics = (containsTopics) => ({
    type: actions.HAS_TOPICS,
    payload: containsTopics
});

export const hasBadges = (containsBadges) => ({
    type: actions.HAS_BADGES,
    payload: containsBadges
});



