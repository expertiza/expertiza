import React, {Component} from 'react'
import {connect} from 'react-redux'
import  Hyperlinks from '../gradesViewTeam/Hyperlinks'
import {Loading} from '../UI/spinner/LoadingComponent';
import * as actions from '../../redux'
import ResponseTable from './responseTable';

class  ResponseViewComponent extends Component {
    constructor(props){
        super(props)
        this.state = {
            main_review: true,
            author_feedback: false,
            toggle_button_main: 'hide',
            toggle_button_feedback: 'unhide',
        }
        this.toggleAuthorFeedback = this.toggleAuthorFeedback.bind(this);
        this.toggleMainReview = this.toggleMainReview.bind(this);
    }
    componentDidMount () {
        this.props.fetchReviewData(this.props.match.params.id)
    }    
    toggleAuthorFeedback = () => {
        this.setState({
            author_feedback: !this.state.author_feedback,
        }, () => {
            this.setState({
                toggle_button: (this.state.author_feedback)?'hide':'unhide'
            })
        })

    }
    toggleMainReview = () => {
        this.setState({
            main_review: !this.state.main_review,
        }, () => {
            this.setState({
                toggle_button_main: (this.state.main_review)?'hide':'unhide'
            })
        })

    }
    render () {
        // eslint-disable-next-line
        let title;
        var options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric',hour: 'numeric', minute: 'numeric', second: 'numeric'  };
        if(!this.props.loading) {
            if ( this.props.survey ) {
                return(
                    title = <h1> {this.props.title} for {this.props.survey_parent.name} </h1>
                )
            }
            else {
                if(this.props.questions.length>0)
                    return(
                        <div>
                            <h1> {this.props.title} for {this.props.assignment.name}</h1>
                            <div className="row" style={{paddingTop: 30}}>
                                 <div className="col">
                                    <b>Submission Links</b>
                                    <Hyperlinks show = {true} links={this.props.contributor} />
                                </div>
                            </div>

                            <ResponseTable title="Review" questions={this.props.questions} answers={this.props.answers} response={this.props.response}
                            toggletable = {this.props.toggleMainReview}
                            type="normal"/>
                            
                            {(this.props.author_response_map!=null)?
                            <div>
                                <br/><h3 style={{float: 'left'}} > Feedback from author </h3>
                                    <a style={{float: 'left', paddingTop: '10px', paddingLeft: '10px'}} href="#!" onClick = {()=>this.toggleAuthorFeedback()}>
                                        {this.state.toggle_button_feedback}
                                    </a><br/>
                                {(this.state.author_feedback)?
                                    <div style={{clear: 'both'}}>
                                    <ResponseTable title="Review" questions={this.props.author_questions} answers = {this.props.author_answers} 
                                    response={this.props.author_response_map[0]} type ="author"/>
                                    </div>:<div> </div>
                                }
                            </div>: <div></div> }
                        </div>
                    )
                else
                    return (
                        <div>
                            <Loading />
                        </div>
                    )
            }
        }
        else{           
            return (
                <div>
                    <Loading />
                </div>
            )
        }
    }
    
 }


const mapStatetoProps = state => {
    return {
        title: state.responseReducer.title,
        assignment: state.responseReducer.assignment,
        loading: state.responseReducer.loading,
        response: state.responseReducer.response,
        questions: state.responseReducer.questions,
        answers: state.responseReducer.ans,
        team: state.studentTaskView.team,
        contributor: state.responseReducer.contributor,
        author_questions: state.responseReducer.author_questions,
        author_answers: state.responseReducer.author_answers,
        author_response_map: state.responseReducer.author_response_map
    }
}

const mapDispatchToProps = dispatch => {
    return {
        fetchReviewData : review_id => dispatch(actions.fetchReviewData(review_id))
    }
}
export default connect(mapStatetoProps, mapDispatchToProps)(ResponseViewComponent);