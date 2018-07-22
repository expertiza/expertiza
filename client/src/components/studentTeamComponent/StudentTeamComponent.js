import React, {Component} from 'react';

class StudentTeamComponent extends Component {
    state = {
        participant_id: null
    }

    componentDidMount () {
        console.log(this.props.match.params.id)
        this.setState({participant_id: this.props.match.params.id})
    }
    render () {
        return (
            <div>
                <h3> In team Component with Participant id: {this.state.participant_id} </h3>
            </div>
        )
    }
}

export default StudentTeamComponent;