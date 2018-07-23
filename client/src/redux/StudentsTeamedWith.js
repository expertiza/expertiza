import * as ActionTypes from './ActionTypes';


export const StudentsTeamedWith = (state={ studentsTeamedWith:{ } }, action) => {
    switch(action.type){
        case ActionTypes.ADD_STUDENTSTEAMEDWITH:
            return {...state, studentsTeamedWith: action.payload};
        default: 
            return state;
    }
};