import * as ActionTypes from './ActionTypes';


export const studentTasks = (state={ studentTasks:{ } }, action) => {
    switch(action.type){
        case ActionTypes.ADD_STUDENTTASKS:
            return {...state, studentTasks: action.payload};
        default: 
            return state;
    }
};