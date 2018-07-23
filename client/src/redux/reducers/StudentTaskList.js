import * as actions from '../index'

const initialize={
         studentsTeamedWith:{ },
         studentTasks: []
    }

const studentTaskList = (state = initialize, action) => {
    switch(action.type){
        case actions.ADD_STUDENTSTEAMEDWITH:
            return {...state, studentsTeamedWith: action.payload};
        case actions.ADD_STUDENTTASKS:
            return {...state, studentTasks: action.payload};
        default: 
            return state;
    }
};

export default studentTaskList;