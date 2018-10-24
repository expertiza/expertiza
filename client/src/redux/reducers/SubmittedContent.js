import * as actions from '../index'
import {updateObject}  from '../../shared/utility/utility'


const initialize={
        loaded : false, 
        submitted_content: {}
    }

const submittedContent = (state = initialize, action) => {
    
    switch(action.type){
        case actions.ADD_SUBMITTEDCONTENT:
            return updateObject(state = initialize , {
                    loaded: true,
                    submitted_content: action.payload
                }) 
            
        
        default: 
            return state;
    }
};

export default submittedContent;