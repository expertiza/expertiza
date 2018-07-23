import * as actions from '../index';

export const Institutions = (state={ institutions:{ }}, action) => {
    switch(action.type){
        case actions.ADD_INSTITUTIONS:
            return {...state, institutions: action.payload};
        default: 
            return state;
    }
};