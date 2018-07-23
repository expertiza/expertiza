import React, { Component } from 'react';

class StudentQuizzesComponent extends Component {



    render () {

        return (
            <div>
                <h3> in student quizzess component : {this.props.match.params.id} </h3>
            </div>
        )
    }
}

export default StudentQuizzesComponent;