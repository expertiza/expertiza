import React, { Component} from 'react'

class GradesViewMyScores extends Component {

    render () {

        return (
            <div>In grades view my scores : {this.props.match.params.id}</div>
        )
    }
}
export default GradesViewMyScores;