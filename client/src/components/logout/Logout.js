import React, {Component} from 'react';
import {connect} from 'react-redux'
import * as actions from '../../redux'
import {Redirect} from 'react-router-dom'

class Logout extends Component {
    componentDidMount = () => {
        this.props.onLogout();
    }

    render() {
        return (
            <div>
                <Redirect to='/login'/>
            </div>
        )
    }
}

const mapDispatchToProps = dispatch => {
    return {
        onLogout: () => dispatch(actions.logOut())
    }
}

export default connect(null, mapDispatchToProps)(Logout);