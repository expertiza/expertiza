import React, {Component} from 'react';
import { connect } from 'react-redux'
import * as actions from '../../redux'
import { NavLink } from 'react-router-dom';
import Aux from '../../hoc/Aux/Aux'
import { Loading } from '../UI/spinner/LoadingComponent';
import { Alert } from 'reactstrap';
class SignUpSheetComponent extends Component {

    
    componentDidMount () {
        console.log(this.props.match.params)
        console.log(this.props.match.params.flag)
        this.props.onSignUpSheetLoad(this.props.match.params.id, true);
        console.log(this.props.loaded);
    }

    componentDidUpdate (prevProps) {
        console.log("PrePropsmsg",prevProps.error_msg)
        console.log("CurrProps", this.props.error_msg)
        if (this.props.error_msg != prevProps.error_msg){
            this.props.onSignUpSheetLoad(this.props.match.params.id, false);
        }
    }


    onSignUp (topic_id){
        console.log(topic_id, this.props.assignment.id);

        this.props.onSignUp(this.props.match.params.id, topic_id, this.props.assignment.id)
        console.log("Return")
    }

    onDelete (topic_id){
        this.props.onDelete(this.props.match.params.id, topic_id, this.props.assignment.id)
    }

    render() {
        let loading;
        let signupsheet;
            if(this.props.loaded){
               signupsheet =  <div className="main_content">
                {this.props.error_msg.error == undefined || this.props.error_msg.error == "" ? 
                console.log()
                    :
                <Alert color='danger'>{this.props.error_msg.error}</Alert>
                }
                {this.props.error_msg.success == undefined || this.props.error_msg.success == "" ?
                console.log()
                    :
                <Alert color='success'>{this.props.error_msg.success}</Alert>
                }
                <h1>Signup sheet for {this.props.assignment.name}</h1>
                <br></br>
                {this.props.sign_up_topics.map(sign_up_topic =>(
                    sign_up_topic.color == "yellow" ?
                    <div><b>Your topic(s):</b> {sign_up_topic.topic.topic_name} <br/></div> :
                    console.log()
                ))}
                
                <br></br>

                <table class="general">
                    <tbody>
                        
                        <tr>
                            <th width="5%">Topic #</th> 
                            <th width="50%">Topic name(s)</th>
                            <th width="5%">Num. of slots</th>
                            <th width="5%">Available slots</th>
                            <th width="5%">Num. on waitlist</th>
                            <th width="10%">Bookmarks</th>
                            <th width="10%">Actions</th>
                            <th width="10%">Advertisements</th>
                        </tr>
                        {this.props.sign_up_topics.map(sign_up_topic =>(
                            <tr bgcolor = {sign_up_topic.color}>
                                <td>{sign_up_topic.topic.topic_identifier}</td>
                                <td>{sign_up_topic.topic.topic_name}</td>
                                <td align = "center">{sign_up_topic.topic.max_choosers}</td>
                                <td align = "center">{sign_up_topic.available_slots}</td>
                                <td align = "center">{sign_up_topic.num_waiting}</td>
                                <td><span className="fa-stack fa-md">
                                    <i className="fa fa-bookmark fa-stack-1x fa-2x"></i>
                                    <i className="fa fa-plus fa-stack-1x fa-inverse" styles={'font-size: .5em'}></i>
                                </span></td>
                                <td align = "center">{sign_up_topic.color == ""  ?
                                // <Button onClick={this.onSignUp(sign_up_topic.topic.id)}></Button>:
                                 <img src='../assets/images/Check-icon.png' onClick={() => this.onSignUp(sign_up_topic.topic.id)}></img> : 
                                 <img src='../assets/images/delete_icon.png' onClick={() => this.onDelete(sign_up_topic.topic.id)}></img>}
                                 </td>
                                 <td/>
                            </tr>
                        ))}
                        
                    </tbody>
                </table> 

                <NavLink to={`/studentlist`}>back</NavLink>   
            </div>
            }

            else{
                loading = <Loading/>
            }
            return (
                <Aux>
                    <div >
                        {loading}
                    </div>
                    <div>
                        {signupsheet}
                    </div>
                </Aux>
            )
    }
}

const mapStateToProps = state => {
    return {
        loaded: state.signUpSheetList.loaded,
        assignment: state.signUpSheetList.signupsheet.assignment,
        sign_up_topics: state.signUpSheetList.signupsheet.sign_up_topics,
        error_msg: state.signUpSheetList.alertMsg
    }
}

const mapDispatchToProps = dispatch => {
    return {
        onSignUpSheetLoad: (id, flag) => { dispatch(actions.onSignUpSheetLoad(id, flag))},
        onSignUp: (id, topic_id, assignment_id) => {dispatch(actions.onSignUp(id, topic_id, assignment_id))},
        onDelete: (id, topic_id, assignment_id) => {dispatch(actions.onDelete(id, topic_id, assignment_id))}
    }
}
export default connect(mapStateToProps, mapDispatchToProps)(SignUpSheetComponent);