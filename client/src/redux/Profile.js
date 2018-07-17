import * as ActionTypes from './ActionTypes';


export const Profile = (state={ profile:{ }, aq: { }, errMess: null}, action) => {
    switch(action.type){
        case ActionTypes.ADD_PROFILE:
            return {...state, profile: action.payload.response['user'], aq: action.payload.response['aq'], errMess: null};
        case ActionTypes.PROFILE_FAILED:
            return {...state, errMess: action.payload };
        case ActionTypes.EDIT_PROFILE:
            return {...state, profile: action.payload.response['user'], aq: action.payload.response['aq'], errMess: action.payload.servermsg};
        default: 
            return state;
    }
};