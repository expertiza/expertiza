import React, { Component } from 'react';
import axios from 'axios';

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
        axios({
            method: 'post',
            url: 'http://localhost:3001/api/v1/password_retrieval/forgottenPasswordSendLink',
            headers: { "Content-Type": "application/json"},
            data: { "user": { "email" : this.state.email} }
        })
        .then(response => {
            console.log(response)
            // localStorage.setItem('jwt', response.data.jwt)
            // this.props.history.push('/')
        })
        .catch(error => {
                        console.log(error)
                        alert('Something went wrong. adding the log: ', error)
                        this.props.history.push('/login')
                        } )
    }
    
    render () {

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

export default PasswordForgotten;