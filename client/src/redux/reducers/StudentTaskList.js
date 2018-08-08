import * as actions from '../index'

const initialize={
         studentsTeamedWith:{ },
         studentTasks: [],
         teamCourse: []
    }

const studentTaskList = (state = initialize, action) => {
    switch(action.type){
        case actions.ADD_STUDENTSTEAMEDWITH:
            return {...state, studentsTeamedWith: action.payload};
        case actions.ADD_STUDENTTASKS:
            return {...state, studentTasks: action.payload};
        case actions.ADD_TEAMCOURSE:
            return {...state, teamCourse: action.payload};
        case actions.ADD_TASKS:
            return {...state, tasks_not_started: action.payload};
        default: 
            return state;
    }
};

export default studentTaskList;