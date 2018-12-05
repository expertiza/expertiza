import React, { Component } from 'react'
import { connect } from 'react-redux'
import * as actions from '../../redux'
import { Input, Label, Text } from 'reactstrap'
class StudentReviewListComponent extends Component {
    constructor(props){
        super(props)
        this.state={
            viewtopic :true,
        }
        this.toggletopic = this.toggletopic.bind(this)
    }
    toggletopic = () => {
        this.setState({
            viewtopic: !this.state.viewtopic
        }) 
    }
    render () {
        if(this.props.topics){
            return (
                <div>
                    <div className="main-content">
                        <h2>Reviews for "{this.props.assignment.name}"</h2>
                        {/* {(this.props.assignment.num_reviews_allowed || this.props.assignment.num_reviews_allowed === -1)?<h4></h4> 
                            : */}
                         <h5>Number of reviews allowed:{this.props.assignment.num_reviews_allowed}</h5>
                         <h5>You are required to do {this.props.assignment.num_reviews_required} reviews</h5>
                         <Input style={{marginLeft:5, width:18, height:18 }} type="checkbox" onChange={this.toggletopic} id="toggletopic"/>
                         <Label style={{marginLeft:25}} htmlFor="toggletopic">I don't care which topic I review</Label><br/>
                         <Label style={{fontWeight: "bold"}}> Select a topic below to begin a new review:</Label>
                         {(this.state.viewtopic)?
                            <table cellpadding="0" id="topic_list">
                                { this.props.topics.map((e)=>
                                        <tr> <font color="gray">{e.topic_identifier + ":" + e.topic_name} </font></tr>
                                )}
                            </table>:<div></div>
                        }
                    </div>
                </div>
            )
        }
        else{
            return(
                <div></div>
            )
        }
    }
}
const mapDispatchToProps = dispatch => {
    return {
    }
}
const mapStateToProps = state => {
    return {
        topics: state.studentTaskView.topics,
        assignment: state.studentTaskView.assignment
    }
}

export default connect(mapStateToProps, mapDispatchToProps)(StudentReviewListComponent);