import * as actions from '..';

const Grades = (state = {
    questionnaires: {},
    vm: {},
    total: null,
    team_name: "",
    err: null
},action) =>{
    switch(action.type){
        case actions.ADD_SCORE:
            return {...state, 
                    questionnaires: action.payload.questionnaires,
                    vm: action.payload.vm,
                    total: action.payload.total,
                    team_name: action.payload.team_name
                }
        default: 
            return state;
    }
};

export default Grades;