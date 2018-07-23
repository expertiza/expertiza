import React, {Component} from 'react';
class SignUpSheetComponent extends Component {

    render() {
        return (
            <div> In signup sheet component with id: {this.props.match.params.id}</div>
        )
    }
}

export default SignUpSheetComponent;