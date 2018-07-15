import * as ActionTypes from './ActionTypes';


export const Profile = (state={ profile:{ }, aq: { }, errMess: null}, action) => {
    switch(action.type){
        case ActionTypes.ADD_PROFILE:
            return {...state, profile: action.payload['user'], aq: action.payload['aq'], errMess: null};
        case ActionTypes.PROFILE_FAILED:
            return {...state, errMess: action.payload };
        default: 
            return state;
    }
};