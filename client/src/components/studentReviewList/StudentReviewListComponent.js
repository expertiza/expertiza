import React, { Component } from 'react';

class StudentReviewListComponent extends Component {


    render () {
        return (
            <div> In student Review list component : {this.props.match.params.id} </div>
        )
    }
}

export default StudentReviewListComponent;