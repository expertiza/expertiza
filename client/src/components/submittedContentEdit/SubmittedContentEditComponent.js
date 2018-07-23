import React, { Component} from 'react';

class SubmittedContentEditComponent extends Component {

    render () {
        return (
            <div>
                <h3> In submitted Edit Component : {this.props.match.params.id} </h3>
             </div>
        )
    }
}

export default SubmittedContentEditComponent;