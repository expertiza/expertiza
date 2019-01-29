import React, { Component } from 'react'
import { connect } from 'react-redux'
import {fetchAssignmentReviewData} from '../../redux/actions/StudentReview'
import {reviewNewTopic} from '../../redux/actions/StudentReview'
import { Input, Label, Text } from 'reactstrap'
import {Loading } from './../UI/spinner/LoadingComponent'
import { NavLink } from 'react-router-dom';
import moment from 'moment'

class StudentReviewListComponent extends Component {
    constructor(props){
        super(props)
        this.state={
            viewtopic :true,
            selected_topic: {}
        }
        this.toggletopic = this.toggletopic.bind(this)
        this.handleChange = this.handleChange.bind(this)
        this.newReview = this.newReview.bind(this)
    }

    newReview = (assignment_id, profile_id, topic_id) => {
        reviewNewTopic(assignment_id, profile_id, topic_id).
        then(()=> this.props.loadReviewData(this.props.match.params.id))
    }

    componentDidMount = () =>{
        this.props.loadReviewData(this.props.match.params.id)
    }

    toggletopic = () => {
        this.setState({
            viewtopic: !this.state.viewtopic
        }) 
    }
    handleChange = (e) => {
        this.setState({
            selected_topic: e.target.value
        });
    }
    render () {
        if(this.props.non_reviewable_topics){
            return (
                <div>
                    <div className="main-content">
                        <h2>Reviews for "{this.props.assignment.name}"</h2>
                        {/* {(this.props.assignment.num_reviews_allowed || this.props.assignment.num_reviews_allowed === -1)?<h4></h4> 
                            : */}
                         <h5>Number of reviews allowed:{this.props.assignment.num_reviews_allowed}</h5>
                         <h5>You are required to do {this.props.assignment.num_reviews_required} reviews</h5>
                         {(this.props.candidate_reviews_started.length>0)?
                         <table cellpadding="0" className="table_topic_list">
                         {this.props.candidate_reviews_started.map((i, index) => 
                         <tr>
                             <td>
                                <b>Review {index+1}.</b>
                                <font> {i.id +":"+ i.name}</font>
                                <NavLink to={`/response/view/${i.latest_response_id}`}> View </NavLink>
                                {/* add navlink to the edit form  */}
                                <NavLink to={``}> edit </NavLink>
                                <font>{"  -- latest update at  " +moment(new Date(i.map.updated_at)).format('MMMM Do YYYY, hh:mm')}</font>
                             </td>
                         </tr>
                         )}
                          </table>: <div></div>

                        }
                         <br/>
                         <Input style={{marginLeft:5, width:18, height:18 }} type="checkbox" onChange={this.toggletopic} id="toggletopic"/>
                         <Label style={{marginLeft:30}} htmlFor="toggletopic">I don't care which topic I review</Label><br/>
                         <Label style={{fontWeight: "bold"}}> Select a topic below to begin a new review:</Label>
                         {(this.state.viewtopic)?
                            <table cellpadding="0" className="table_topic_list">
                                { this.props.candidate_topics_to_review.map((e)=>
                                        <tr> 
                                            <Input type="radio" name="selected_topic" value={e.id} onChange={this.handleChange}/>
                                                <font>
                                                    {e.topic_identifier + ":" + e.topic_name}
                                                </font>
                                        </tr>
                                )}
                                {
                                    this.props.non_reviewable_topics.map((e)=>
                                    <tr> <font color="gray">{e.topic_identifier + ":" + e.topic_name} </font></tr>
                                )}
                            </table>:<div></div>
                        }
                        <button onClick={()=> 
                            // console.log(this.state.selected_topic)}>
                             this.newReview(this.props.assignment.id,this.props.profile_id,this.state.selected_topic)}>
                        Request a new submission to review</button>
                    </div>
                </div>
            )
        }
        else{
            return(
                <div>
                    <Loading />
                </div>
            )
        }
    }
}
const mapDispatchToProps = dispatch => {
    
    return {
        loadReviewData: (id) => dispatch(fetchAssignmentReviewData(id)),
        // reviewNewTopic: (assignment_id, user_id, topic_id) => dispatch(reviewNewTopic(assignment_id, user_id, topic_id))
    }
}
const mapStateToProps = state => {
    return {
        candidate_reviews_started: state.assignmentReviewData.candidate_reviews_started,
        non_reviewable_topics: state.assignmentReviewData.non_reviewable_topics,
        candidate_topics_to_review: state.assignmentReviewData.candidate_topics_to_review,
        assignment: state.studentTaskView.assignment,
        profile_id: state.profile.profile.id
    }
}

export default connect(mapStateToProps, mapDispatchToProps)(StudentReviewListComponent);