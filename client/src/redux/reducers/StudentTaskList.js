import * as actions from '../index'

const initialize={
         studentsTeamedWith:{ },
         studentTasks: [],
         teamCourse: [],
         tasks_not_started: [],
         taskrevisions: [],
         hasTopics: {},
         hasBadges: {}
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
        case actions.ADD_TASKREVISIONS:
            return {...state, taskrevisions: action.payload};
        case actions.HAS_TOPICS:
            return {...state, hasTopics: action.payload};
        case actions.HAS_BADGES:
            return {...state, hasBadges: action.payload};
        default: 
            return state;
    }
};

export default studentTaskList;