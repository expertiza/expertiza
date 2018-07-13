import React, { Component } from 'react'

class PasswordForgottenUpdate extends Component {
    state = {
        email: '',
        Password: '',
        rePassword: ''
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
        
    }

    render () {

        return (
            <div className="container" style={{marginTop: '10px'}}>
            <div className="row">
                <div className="col-md-6">
                <h4>Forgotten Your Password?</h4>
                <div className="row">
                    <div className="form-group">
                        <label >Email</label>
                        <input onChange={onEmailChangeHandler} className="form-control" id="usr" />
                    </div>
                    <div className="form-group">
                        <label >Enter new Password </label>
                        <input onChange={onPasswordChangeHandler} className="form-control" id="usr" />
                    </div>
                    <div className="form-group">
                        <label >Enter the new Password Again </label>
                        <input onChange={onRePasswordChangeHandler} className="form-control" id="usr" />
                    </div>
    
                </div>
                
                <div className="row">
                    <button type="submit" className="btn btn-danger" onSubmit={ this.onSubmitPasswordUpdateHandler }>Submit</button>
                </div>
                </div>
            </div>
        </div>
        )
    }
    
}

export default PasswordForgottenUpdate;