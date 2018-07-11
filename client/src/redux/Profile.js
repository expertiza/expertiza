import * as ActionTypes from './ActionTypes';


export const Profile = (state={ profile:{ }, aq: { }}, action) => {
    switch(action.type){
        case ActionTypes.ADD_PROFILE:
            return {...state, profile: action.payload['user'], aq: action.payload['aq']};
        default: 
            return state;
    }
};