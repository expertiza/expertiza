import React, { Component } from 'react' 
import { connect } from 'react-redux'
import * as actions from '../../redux/index'
import { NavLink } from 'react-router-dom';

class StudentTaskView extends Component {

    componentDidMount () {
        this.props.onLoad();
    }

    signUpSheetHandler = () =>  {

    }

    view_student_teams_path_handler = () => {
        // view_student_teams_path(student_id: @participant.id)
    }

    submission_allowed_handler = () => {
        // assignment.submission_allowed(this.topic_id)
        return true
    }

    your_work_handler = () => {
        // :controller => 'submitted_content', :action => 'edit', :id => @participant.id
    }

    student_review_handler = () => {
// ,{:controller => 'student_review', :action => 'list', :id => @participant.id} 
    }

    getAliasName = () => {
        let alias_name;
        if (this.props.authorization !== 'reader') {
            alias_name = "Others' work"
        }else {
            alias_name = "Your readings"
        }
        return alias_name
    }

    render () {

        let assign_name;
        let link;
        let panel;
        if(this.props.loaded){
            assign_name = (this.props.assignment.spec_location === null|| this.props.assignment.spec_location.length===0) ?
                 <div>
                    <h1> Submit or Review work for { this.props.assignment.name} </h1> 
                    <div class="flash_note">
                        Next: Click the activity you wish to perform on the assignment titled: { this.props.assignment.name }
                    </div>
                </div> : <h1> Submit or Review work for  link_to @assignment.name, @assignment.spec_location </h1>

            link = ( this.props.assignment.spec_location && this.props.assignment.spec_location.length > 0 ) ?
                  <NavLink className="nav-link" to="#assignment.spec_location">Assignment Description</NavLink> : null;
                   
            panel = <div class="list-group col-md-5">
                       {
                        (this.props.topics.length === 0) ? 
                             (this.props.authorization === 'participant' || this.props.authorization === 'submitter') ? 
                                    <li><NavLink to="#" 
                                        onClick = {this.signUpSheetHandler}
                                        class="list-group-item list-group-item-action">
                                    Signup sheet (Sign up for a topic)
                                </NavLink></li> :null :null
                       } 
                       {/* ACS Here we need to know the size of the team to decide whether or not to display the label "Your team" in the student assignment tasks */}
                       {
                        (this.props.assignment.max_team_size < 1) ? this.props.authorization === 'participant' ?
                                    <li><NavLink to='#' 
                                                 onClick={this.view_student_teams_path_handler} 
                                                 class="list-group-item list-group-item-action" >
                                        Your team (View and manage your team) </NavLink></li> : null :null
                       }
                       {/* Your Work */}
                       {
                        (this.props.authorization === 'participant' || this.props.can_submit === true) ?
                             (this.props.topics.size > 0) ? 
                                    (this.props.topic_id && this.submission_allowed_handler) ?
                                        <NavLink to="#" onClick={this.your_work_handler} class="list-group-item list-group-item-action" > 'Your work' (Submit and view your work) </NavLink    > :
                                        <div><font color="gray">Your work</font> <p>(You have to choose a topic first)</p></div>
                           :
                            (this.submission_allowed_handler) ? <NavLink to="#" onClick={this.your_work_handler} class="list-group-item list-group-item-action" > Your work (Submit and view your work) </NavLink>
                                :<div><font color="gray">Your work</font> <p>(You are not allowed to submit your work right now)</p></div>
                        : null 
                       }
                       
                       
                <a href="#" class="list-group-item list-group-item-action">Dapibus ac facilisis in</a>
                <a href="#" class="list-group-item list-group-item-action">Morbi leo risus</a>
                <a href="#" class="list-group-item list-group-item-action">Porta ac consectetur ac</a>
                <a href="#" class="list-group-item list-group-item-action disabled">Vestibulum at eros</a>
            </div>
        }else {
            assign_name = 'loading...'
        }

        return (
            <div>
                {assign_name}
                {link}
                {panel}
            </div>
        )
    }

}

const mapStateToProps = state => {
    return {
        participant: state.studentTaskView.participant,
        can_submit : state.studentTaskView.can_submit,
        can_review: state.studentTaskView.can_review,
        can_take_quiz: state.studentTaskView.can_take_quiz,
        authorization: state.studentTaskView.authorization,
        team : state.studentTaskView.team,
        denied: state.studentTaskView.denied,
        assignment: state.studentTaskView.assignment,
        can_provide_suggestions: state.studentTaskView.can_provide_suggestions,
        topic_id: state.studentTaskView.topic_id,
        topics: state.studentTaskView.topics,
        timeline_list: state.studentTaskView.timeline_list,
        loaded: state.studentTaskView.loaded
    }
}

const mapDispatchToProps = dispatch => {
    return {
        onLoad: () => { dispatch(actions.onLoad())}
    }
}
export default connect(mapStateToProps, mapDispatchToProps)(StudentTaskView);