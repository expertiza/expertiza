import React, {Component} from 'react'
import {connect} from 'react-redux'

import {Loading} from '../UI/spinner/LoadingComponent';
import * as actions from '../../redux/index'


class  ResponseViewComponent extends Component {

    
    componentDidMount () {
        this.props.fetchReviewData(this.props.match.params.id)
    }    

    render () {
        let title;
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
                            <table className="table">
                                {this.props.questions.map((i, index) =>
                                    <tr className={(index%2)==0?"table-warning":"table-info"}>
                                        <tbody>
                                            <tr key={"question_"+index}>
                                                <td ><span style={{"fontWeight":"bold"}}>{index+1 +". "+i.txt}</span></td>
                                            </tr>
                                            <table>
                                                <tr key={"answer_"+index} className={(index%2)==0?"table-warning":"table-info"}>
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
        map: state.responseReducer.map,
        survey: state.responseReducer.survey,
        survey_parent: state.responseReducer.survey_parent,
        title: state.responseReducer.title,
        assignment: state.responseReducer.assignment,
        loading: state.responseReducer.loading,
        questions: state.responseReducer.questions,
        answers: state.responseReducer.ans
    }
}

const mapDispatchToProps = dispatch => {
    return {
        fetchReviewData : review_id => dispatch(actions.fetchReviewData(review_id))
    }
}
export default connect(mapStatetoProps, mapDispatchToProps)(ResponseViewComponent);