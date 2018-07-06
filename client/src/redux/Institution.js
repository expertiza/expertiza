import * as ActionTypes from './ActionTypes';


export const Institutions = (state={ institutions:{ }}, action) => {
    switch(action.type){
        case ActionTypes.ADD_INSTITUTIONS:
            return {...state, institutions: action.payload};
        default: 
            return state;
    }
};