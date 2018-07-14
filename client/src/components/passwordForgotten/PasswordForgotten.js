import React, { Component } from 'react';
import {connect } from 'react-redux';
import * as actions from '../../redux/index'

class PasswordForgotten extends Component {
    state = {
        email: ''
    }
    
    onEmailChangeHandler = (e) => {
        console.log(e.target.value)
        this.setState({email: e.target.value})
    }

    onEmailSubmit = () => {
        console.log('in email submit fhandler')
       this.props.onEmailSubmitForPasswordReset(this.state.email)
    }
    
    render () {
        let output = (
            <div className="container" style={{marginTop: '10px'}}>
                <div className="row">
                    <div className="col-md-6">
                    <h4>Forgotten Your Password?</h4>
                    <div className="row">
                        <div className="form-group">
                            <label >Enter the e-mail address associated with your account:</label>
                            <input onChange={this.onEmailChangeHandler} className="form-control" id="usr" />
                        </div>
                    </div>
                    
                    <div className="row">
                        <button type="submit" className="btn btn-danger" onClick={this.onEmailSubmit}>Submit</button>
                    </div>
                    </div>
                </div>
            </div>
        )
        output = this.props.passwordResetEmailSent ? <p>A link to reset your password has been sent to your e-mail address.</p> : output;
        return (
            <div className="container" style={{marginTop: '10px'}}>
                <div className="row">
                    <div className="col-md-6">
                    <h4>Forgotten Your Password?</h4>
                    <div className="row">
                        <div className="form-group">
                            <label >Enter the e-mail address associated with your account:</label>
                            <input onChange={this.onEmailChangeHandler} className="form-control" id="usr" />
                        </div>
                    </div>
                    
                    <div className="row">
                        <button type="submit" className="btn btn-danger" onClick={this.onEmailSubmit}>Submit</button>
                    </div>
                    </div>
                </div>
            </div>
        )

    }
}

const mapStateToProps = state => {
    return {
        passwordResetEmailSent: state.auth.passwordResetEmailSent
    }
}
const mapDispatchToProps = dispatch => {
    return {
        onEmailSubmitForPasswordReset: (email) => dispatch(actions.passwordResetEmailSend(email))
    }
}

export default connect(mapStateToProps, mapDispatchToProps)(PasswordForgotten);