import React, {Component} from 'react';

class GradesViewTeamComponent extends Component {


    render () {

        return (
            <div>
                <h3> In grades view team Component: {this.props.match.params.id}</h3>
            </div>
        )
    }
}

export default GradesViewTeamComponent;