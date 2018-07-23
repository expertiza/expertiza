import React, { Component } from 'react';
import {connect } from 'react-redux';
import * as actions from '../../redux'

class PasswordForgotten extends Component {
    state = {
        email: '',
        username: ''
    }
    
    onEmailChangeHandler = (e) => {
        this.setState({email: e.target.value})
    }
    
    onUsernameChangeHandler = (e) => {
        this.setState({username: e.target.value})
    }

    onEmailSubmit = () => {
        if(!this.props.usernameForget) {
            this.props.onEmailSubmitForPasswordReset(null, this.state.username)
        }else {
            this.props.onEmailSubmitForPasswordReset(this.state.email, null)
        }
    }
    
    render () {
        const inputText = !this.props.usernameForget ? 
                            (<div className="form-group">
                                <label >Enter the username associated with your account:</label>
                                <input onChange={this.onUsernameChangeHandler} className="form-control" id="usr" />
                            </div>) : 
                            (<div className="form-group">
                                <label >Enter the e-mail address associated with your account:</label>
                                <input onChange={this.onEmailChangeHandler} className="form-control" id="usr" />
                            </div>)
                            
        let output = (
            <div className="container" style={{marginTop: '10px'}}>
                <div className="row">
                    <div className="col-md-6">
                    <h4>Forgotten Your Password?</h4>
                    <div className="row">
                        {inputText}
                    </div>
                    
                    <div className="row">
                        <button type="submit" className="btn btn-danger" onClick={this.onEmailSubmit}>Submit</button>
                    </div>
                    </div>
                </div>
            </div>
        )
        output = this.props.passwordResetEmailSent ? <p>A link to reset your password has been sent to your e-mail address.</p> : output;
        return output
    }
}

const mapStateToProps = state => {
    return {
        passwordResetEmailSent: state.auth.passwordResetEmailSent,
        usernameForget: state.auth.usernameForget
    }
}
const mapDispatchToProps = dispatch => {
    return {
        onEmailSubmitForPasswordReset: (email, username) => dispatch(actions.passwordResetEmailSend(email, username))
    }
}

export default connect(mapStateToProps, mapDispatchToProps)(PasswordForgotten);