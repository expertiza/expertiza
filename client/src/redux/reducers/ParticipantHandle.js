import * as actions from '..';

const PaticipantHandle = (state = {participant_handle:{}, err: null}, action)=>{
    switch(action.type){
        case actions.PARTICIPANT_HANDLE_FAILURE:
            return {...state, errmess: action.payload};
        case actions.PARTICIPANT_HANDLE_CHANGE:
            return {...state, participant_handle: action.payload}  
        default: 
            return state;  
    }
};

export default PaticipantHandle;