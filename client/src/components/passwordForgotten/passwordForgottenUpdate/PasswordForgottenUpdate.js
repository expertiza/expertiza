import React, { Component } from 'react'
import querystring from 'query-string'
import {connect} from 'react-redux'
import {Redirect} from 'react-router-dom'
import * as actions from '../../../redux/index'

class PasswordForgottenUpdate extends Component {
    state = {
        email: '',
        Password: '',
        rePassword: '',
        token: ''
    }

    componentDidMount () {
        console.log(this.props.location.search)
        const queryStringObj = querystring.parse(this.props.location.search)
        const token = queryStringObj.token
        this.setState({token: token})
    }

    onEmailChangeHandler = (e) => {
        this.setState({email: e.target.value})
    }

    onPasswordChangeHandler = (e) => {
        this.setState({password: e.target.value})
    }

    onRePasswordChangeHandler = (e) => {
        this.setState({rePassword: e.target.value})
    }

    onSubmitPasswordUpdateHandler = () => {
        this.props.onForgetPasswordSubmit(this.state.email, this.state.password, this.state.rePassword, this.state.token)
    }

    render () {
        let output = (
            <div className="container" style={{marginTop: '10px'}}>
            <div className="row">
                <h4>Specify a new password for user:  </h4> <br />
                <div className="col-md-4 col-md-offset-4">
                    <div className="row">
                        <div className="form-group">
                            <label >Email </label>
                            <input onChange={this.onEmailChangeHandler} className="form-control" id="usr" />
                        </div>
                        <br />
                        <div className="form-group">
                            <label >Password </label>
                            <input type="password" onChange={this.onPasswordChangeHandler} className="form-control" id="usr" />
                        </div>
                        <br />
                        <div className="form-group">
                            <label >Confirm Password</label>
                            <input type="password" onChange={this.onRePasswordChangeHandler} className="form-control" id="usr" />
                        </div>
                    </div>
                    <div className="row">
                        <button type="submit" className="btn btn-danger" onClick={ this.onSubmitPasswordUpdateHandler }>Submit</button>
                    </div>
                </div>
            </div>
        </div>
        )
        output = this.props.isPasswordresetSuccess ?  <Redirect to="/login" /> : output ;
        return output;
    }
    
}


const mapStateToProps = state  => {
    return {
        isPasswordresetSuccess: state.auth.isPasswordresetSuccess
    }
}
const mapDispatchToProps = dispatch => {
    return {
        onForgetPasswordSubmit: (name, password, repassword, token) => 
                            dispatch(actions.forgetPasswordUpdate(name, password, repassword, token))
    }
}
export default connect(mapStateToProps, mapDispatchToProps)(PasswordForgottenUpdate);