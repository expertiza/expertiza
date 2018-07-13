import React, { Component} from 'react';
// import { connect} from 'react-redux';
import axios from 'axios';
import {NavLink} from 'react-router-dom'

class Login extends Component {
    state = {
        username: '',
        password: ''
    }

    onSubmitHandler = (event) => {
        event.preventDefault();
        console.log(event);
        axios({
            method: 'post',
            url: 'http://localhost:3001/api/v1/sessions',
            headers: { "Content-Type": "application/json"},
            data: {auth: {
                name: this.state.username,
                password: this.state.password
            }}
        })
        .then(response => {
            console.log(response)
            localStorage.setItem('jwt', response.data.jwt)
            this.props.history.push('/')
        })
        .catch(error => {
                        console.log(error)
                        alert('Invalid username or password')
                        this.props.history.push('/login')
                        } )
    }
    usernameChangeHandler = (event) => {
        console.log(event.target.value)
        this.setState({username: event.target.value})
    }

    passwordChangeHandler = (event) => {
        console.log(event.target.value)
        this.setState({password: event.target.value})
    }

  
    render (){
        return (
            <div className="container center" style= {{marginTop:'35px', marginLeft: '560px'}}>
                <div className="row">
                    <div className="col-md-6 col-md-offset-6">
                        <h4> Welcome! </h4><br />
                        <form onSubmit={this.onSubmitHandler}>
                            <div className="form-group">
                                <label >username </label>
                                <input type="username" 
                                        className="form-control" 
                                        placeholder="Enter username" 
                                        value={this.state.username}
                                        onChange={this.usernameChangeHandler}
                                        />
                            </div>
                            <div className="form-group">
                                <label >Password</label>
                                <input type="password"
                                        className="form-control" 
                                        placeholder="Password"
                                        value={this.state.password}
                                        onChange={this.passwordChangeHandler}
                                        />
                            </div>
                                 <NavLink to="/password_retrieval/forgotten" className="pull-right"> Forget password?</NavLink>
                            <div>
                                
                            </div>
                            <div className="row">
                                <button type="submit" className="btn btn-danger">Submit</button>
                            </div>
                            <br />
                            <div className="row"> 
                                <button type="submit" className="btn btn-danger">Request account</button>
                            </div>
                        </form>
                </div>
            </div> 
        </div>
        )
    }
}
// const mapStatetoProps
export default Login;