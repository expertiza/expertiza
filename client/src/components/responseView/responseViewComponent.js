import React, {Component} from 'react'
import {connect} from 'react-redux'
import  Hyperlinks from '../gradesViewTeam/Hyperlinks'
import {Loading} from '../UI/spinner/LoadingComponent';
import * as actions from '../../redux/index'


class  ResponseViewComponent extends Component {
  
    componentDidMount () {
        this.props.fetchReviewData(this.props.match.params.id)
    }    

    render () {
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
                            <div className="row" style={{paddingTop: 20, paddingLeft: 20}}>
                                <table width="100%">
                                    <tbody>
                                        <tr>
                                            <td align="left" width="70%"><b>Review</b></td>
                                            <td align="left"><b>Last Reviewed:</b><span>
                                            {(this.props.response.updated_at===null)?'Not Available':
                                        new Date(this.props.response.updated_at.split('T')).toLocaleString("en-US", options)}</span></td> 
                                        </tr>
                                    </tbody>
                                </table>
                                <table className="table">
                                    {this.props.questions.map((i, index) =>
                                        <tr className={(index%2)==0?"table_warning":"table_info"}>
                                            <tbody>
                                                <tr key={"question_"+index}>
                                                    <td ><span style={{"fontWeight":"bold"}}>{index+1 +". "+i.txt}</span></td>
                                                </tr>
                                                <table>
                                                    <tr key={"answer_"+index} className={(index%2)==0?"table_warning":"table_info"}>
                                                            <td>
                                                                <div className={"c"+this.props.answers[index].answer}
                                                                    style={{"width":"30px",
                                                                            "height":"30px",
                                                                            "borderRadius":"50%",
                                                                            "fontSize":"15px",
                                                                            "color":"black",
                                                                            "lineHeight":"30px",
                                                                            "textAlign":"center"}
                                                                            }> 
                                                                    {this.props.answers[index].answer}
                                                                </div>
                                                            </td>
                                                            <td style={{"paddingLeft":"10px"}}>
                                                                {this.props.answers[index].comments}            
                                                            </td>
                                                    </tr>
                                                </table>
                                            </tbody> 
                                        </tr>
                                    )}
                                </table>
                                </div>
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
        contributor: state.responseReducer.contributor
    }
}

const mapDispatchToProps = dispatch => {
    return {
        fetchReviewData : review_id => dispatch(actions.fetchReviewData(review_id))
    }
}
export default connect(mapStatetoProps, mapDispatchToProps)(ResponseViewComponent);