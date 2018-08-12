import React, {Component} from 'react';
import { connect } from 'react-redux';
import { fetchScore } from '../../redux/actions/Grade';
import  Scoretable  from './ScoreTable';

class GradesViewTeamComponent extends Component {
    constructor(props){
        super(props);
    }
    componentDidMount= () => {
        this.props.fetchScore(this.props.match.params.id);
    }
    render () {
        {
            return (
                <div className="container-fluid">
                    <div className="row row-content">
                        <div className="col-12">
                            <h2>Summary Report for assignment: {this.props.assignment} </h2>
                            <h4>Team: {this.props.team_name}</h4>
                            <h4>Average peer review score: {this.props.total} </h4>
                            <Scoretable vm = {this.props.vm} />
                        </div>
                    </div>  
                </div>
            )
        }
    }
}
const mapStatetoProps = state =>{
    if(state.studentTaskView.assignment===null || state.studentTaskView.assignment===undefined){
        return{
            assignment: ""
        }
    }
    else{    
        return{
            assignment : state.studentTaskView.assignment.name,
            questionnaires: state.grades.questionnaires,
            vm: state.grades.vm,
            total: state.grades.total,
            team_name: state.grades.team_name
        }
    }
}

const mapDispatchtoProps = dispatch =>({
    fetchScore: (id) =>dispatch(fetchScore(id))
});
export default connect(mapStatetoProps, mapDispatchtoProps)(GradesViewTeamComponent);