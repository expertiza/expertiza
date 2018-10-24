import React, { Component } from 'react' 
import { connect } from 'react-redux'
import * as actions from '../../redux'
import { NavLink } from 'react-router-dom';
import TimelineComponent from './timeline/TimelineComponent'
import Aux from '../../hoc/Aux/Aux'
import { Loading } from '../UI/spinner/LoadingComponent';

class StudentTaskView extends Component {

    componentDidMount () {
        console.log('id recieved is ;', this.props.match.params.id)
        this.props.onLoad(this.props.match.params.id);
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
        let loading;
        let assign_name;
        let link;
        let panel;
        let timeline;
        if(this.props.loaded){
            assign_name = (this.props.assignment.name !== null|| this.props.assignment.name.length!==0) ?
                 <div style={{marginTop: '10px', padding: '5px'}}>
                    <h1> Submit or Review work for { this.props.assignment.name} </h1> 
                    <div class="flash_note">
                        Next: Click the activity you wish to perform on the assignment titled: { this.props.assignment.name }
                    </div>
                </div> : <h1> Submit or Review work for  link_to @assignment.name, @assignment.spec_location </h1>

            link = ( this.props.assignment.spec_location !==null && this.props.assignment.spec_location.length > 0 ) ?
                  <a href={this.props.assignment.spec_location} className="nav-link">Assignment Description</a> : null;
                   
            panel = <div class="list-group col-md-7 " style={{marginLeft: '25px'}}>
                       {
                        (this.props.topics.length > 0) ? 
                             (this.props.authorization === 'participant' || this.props.authorization === 'submitter') ? 
                             <li><NavLink to={`/sign_up_sheet_list/${this.props.participant.id}`} > Signup sheet
                                    </NavLink> (Sign up for a topic)</li> :null :null
                       } 
                       
                       {/* ACS Here we need to know the size of the team to decide whether or not to display the label "Your team" in the student assignment tasks */}
                       
                       {
                        (this.props.assignment.max_team_size > 1) ? this.props.authorization === 'participant' ?
                                <li><NavLink to={`/view_student_teams/${this.props.participant.id}`} >
                                        Your team</NavLink> (View and manage your team)  </li> : null :null
                       }
                      
                       {/* Your Work */}
                      
                       {
                        (this.props.authorization === 'participant' || this.props.can_submit === true) ?
                             (this.props.topics.size > 0) ? 
                                    (this.props.topic_id && !this.props.submission_allowed) ?
                                        <li><NavLink className="StudentTaskUpload" to={`/submitted_content/${this.props.participant.id}`} >Your work</NavLink> (Submit and view your work)</li> :
                                        <li><font color="gray">Your work</font> <span>(You have to choose a topic first)</span></li>
                           :
                            (!this.props.submission_allowed ) ? <li><NavLink className="StudentTaskUpload" to={`/submitted_content/${this.props.participant.id}/edit`} > Your work (Submit and view your work) </NavLink></li>
                                :<li><font color="gray">Your work</font> <span>(You are not allowed to submit your work right now)</span></li>
                        : null 
                       }
                       {/* <!--alias_name means if one participant is a reader, it will show 'Your readings' to see others' work; if one participant is not a reader, it will show 'Others' work' on the 
                            screen.--> */}

                        {(this.props.authorization === 'participant' || this.props.can_review) ? 
                                 (this.props.check_reviewable_topics || this.props.metareview_allowed || this.props.get_current_stage === "Finished") ?             
                                  <li><NavLink to={`/student_review/list/${this.props.participant.id}`} > { this.getAliasName()} </NavLink> (Give feedback to others on their work)</li>:
                                  <li><font color="gray">{this.getAliasName()}</font> <span>  (Give feedback to others on their work)</span></li>
                                : null
                        }  
                       
                        {/* <!--Quiz--> */}
                        
                        {(this.props.assignment.require_quiz )? 
                            (this.props.authorization === 'participant' || this.props.can_take_quiz ) ?
                                (this.props.assignment.require_quiz && (this.props.quiz_allowed || this.props.get_current_stage === "Finished")) ?
                                    <li><NavLink to={`/student_quizzes/${this.props.participant.id}`} > Take quizzes</NavLink> (Take quizzes over the work you have read) </li> :
                                    <li><font color="gray">Take quizzes</font><span> (Take quizzes over the work you have read)</span></li> 
                                :null
                            : null
                         }
                        
                        {/* Only if the assignment supports self-review and students submitted self-review can he or she view scores. */}
                         
                        { (this.props.team && (this.props.authorization === 'participant' || this.props.can_submit))? 
                            (this.props.assignment.is_selfreview_enabled && this.props.unsubmitted_self_review) ?
                                <li><font color="gray">Your scores</font><span> (You have to submit self-review under 'Your work' before checking 'Your scores'.)</span></li> :
                                <li><NavLink to={`/grades/view_team/${this.props.participant.id}`}>Your scores </NavLink> (View feedback on your work)  &nbsp;
                                    <NavLink to={`/grades/view_my_scores/${this.props.participant.id}`} >Alternate View </NavLink>
                                </li> 
                            : null
                         }
                         
                         { (this.props.can_provide_suggestions ) ? 
                            <li><NavLink to={`/suggestion/new/${this.props.assignment.id}`} >Suggest a topic </NavLink></li> :null
                         }
                        
                        {/*  removed code for survey assignment add in line above && SurveyHelper::is_user_eligible_for_survey?	(@assignment.id, session[:user].id) */}
                        {/* Need to ask prof about survey_response ... No controller found */}
                        { (this.props.get_current_stage === "Complete") ? 
                            <li><NavLink to={`/suggestion/new/${this.props.assignment.id}`} >Take a survey </NavLink> </li>:null
                        }
                        <li><NavLink to={`/changeHandle/${this.props.participant.id}`}> Change your handle</NavLink> (Provide a different handle for this assignment)</li>             
            </div>

             timeline =   this.props.timeline_list ? <TimelineComponent timeline_list={this.props.timeline_list}></TimelineComponent> :null
          
                 
        }else {
            loading = <Loading/>
        }

        return (
            <Aux>
                <div className="container">
                    {loading}
                </div>
                <div className="container-fluid left">
                
                    {assign_name}
                    {link}

                    <div className="row">
                        { panel}
                    </div>
                </div>
                <div className="container-fluid" style={{marginTop: '100px'}}>
                    {timeline}
                </div>
            </Aux>
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
        loaded: state.studentTaskView.loaded,
        submission_allowed: state.studentTaskView.submission_allowed,
        check_reviewable_topics: state.studentTaskView.check_reviewable_topics,
        metareview_allowed: state.studentTaskView.metareview_allowed,
        get_current_stage: state.studentTaskView.get_current_stage
    }
}

const mapDispatchToProps = dispatch => {
    return {
        onLoad: (id) => { dispatch(actions.onLoad(id))}
    }
}
export default connect(mapStateToProps, mapDispatchToProps)(StudentTaskView);