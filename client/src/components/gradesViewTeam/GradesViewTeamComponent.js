import React, {Component} from 'react';
import { connect } from 'react-redux';
import { fetchScore } from '../../redux/actions/Grade';
import  Scoretable  from './ScoreTable';
import { Button } from 'react-bootstrap';
import Hyperlinks from './Hyperlinks';
class GradesViewTeamComponent extends Component {
    constructor(props){
        super(props);
        this.state = {
            showlinks: false
        }
        this.togglelinks = this.togglelinks.bind(this);
    }
    togglelinks = () => {
        this.setState({
            showlinks: !this.state.showlinks
        })
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
                            <h4>Average peer review score: <span className = "c5">{(this.props.total !== null && this.props.total !== undefined && this.props.total % 1 !== 0)?
                                                                                     this.props.total.toFixed(2): this.props.total} </span></h4>
                            <Button onClick={this.togglelinks}> Show Submission </Button>
                            <Hyperlinks show = {this.state.showlinks} team = {this.props.team} /> 
                            <Scoretable vm = {this.props.vm} /><br/>
                            <h4 style ={{'font-weight':'bold', 'display':'inline-block'}}> Grade and comment for submission</h4><br/>
                            <div>Grade: Grade for submission</div>
                            <div>Comment: Comment for submission</div>
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
            team: state.studentTaskView.team,
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