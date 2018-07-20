import * as ActionTypes from './ActionTypes';


export const Profile = (state={ profile:{
        profileform : {
            fullname: "",
            password: "",
            email: "",
            institution_id: 0,
            email_on_review: false,
            email_on_submission: false,
            email_on_review_of_review: false,
            copy_of_emails: false,
            handle: "",
            timezonepref: "",
        }
 }, aq: { 
    notification_limit:  0
 }, errMess: null}, action) => {
    switch(action.type){
        case ActionTypes.ADD_PROFILE:
            return {...state, profile: action.payload.response['user'], aq: action.payload.response['aq'], errMess: null};
        case ActionTypes.PROFILE_FAILED:
            return {...state };
        case ActionTypes.EDIT_PROFILE:
            return {...state, profile: action.payload.response['user'], aq: action.payload.response['aq'], errMess: action.payload.servermsg}; 
        default: 
            return state;
    }
};