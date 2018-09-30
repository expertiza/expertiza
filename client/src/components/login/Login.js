import React, { Component} from 'react';
import { connect} from 'react-redux';
import {NavLink} from 'react-router-dom'
import * as actions from '../../redux/index.js'
import {Redirect} from 'react-router-dom'

class Login extends Component {
    state = {
        username: '',
        password: ''
    } 
    
    componentWillMount () {
        this.props.checkForAutoLogin();
    }

    componentDidUpdate() {
        // console.log('in component did update', this.props.loggedin)
        if(this.props.loggedin) {
            this.props.history.push('/studentlist')
        }
    }

    onSubmitHandler = (event) => {
        event.preventDefault();
        this.props.onSubmit(this.state.username, this.state.password)
        
    }
    usernameChangeHandler = (event) => {
        this.setState({username: event.target.value})
    }

    passwordChangeHandler = (event) => {
        this.setState({password: event.target.value})
    }

    forgetUsernameHandler = () => {
        this.props.onUsernameForget();
    }
  
    componentWillUnmount () {
        console.log('in component will unmount')
            this.props.history.push('/studentlist')
    }

    render (){
        let output =  ( <div className="container center" style= {{marginTop:'35px', marginBottom:'50px'}}>
                            <div className="row justify-content-md-center">
                                <div className="col-md-4 col-md-offset-6">
                                    <div className="text-center">
                                    <h2> Welcome! </h2>
                                    </div>
                                    <form onSubmit={this.onSubmitHandler}>
                                        <div className="form-group">
                                            <label >Username </label>
                                            <input type="username" 
                                                    className="form-control" 
                                                    placeholder="Enter username" 
                                                    value={this.state.username}
                                                    onChange={this.usernameChangeHandler}
                                                    autoComplete={"on"}
                                                    />
                                            <span>
                                                <NavLink to="/password_retrieval/forgotten" onClick={this.forgetUsernameHandler} className="pull-right"> Forgot username?</NavLink>
                                            </span>
                                        </div>


                                        <div className="form-group" style= {{marginTop: '20px', marginBottom: '20px'}}>
                                            <label >Password</label>
                                            <input type="password"
                                                    className="form-control" 
                                                    placeholder="Password"
                                                    value={this.state.password}
                                                    onChange={this.passwordChangeHandler}
                                                    />
                                            <span>
                                                <NavLink to="/password_retrieval/forgotten" className="pull-right"> Forgot password?</NavLink>
                                            </span>
                                        </div>
                                        <br />
                                        <div style={{ marginTop: '20px'}}>
                                            <button type="submit" className="btn btn-danger btn-block">Sign in</button>
                                        </div>
                                        <br />
                                        <div className="text-center" > 
                                            <NavLink to="#" >Request account</NavLink>
                                        </div>
                                    </form>
                                </div>
                            </div> 
                        </div>  ); 
        output = this.props.loggedin ?  <Redirect to="/studentlist" /> : output ;
        return output;
    }
}

const mapStatetoProps = state => {
    return {
        loggedin: state.auth.loggedIn
    }
}

const mapDispatchToProps = dispatch => {
    return {
        onSubmit: (name, password) => {dispatch(actions.auth(name, password))},
        onUsernameForget : () => {dispatch(actions.forgetUsername())},
        checkForAutoLogin : () => { dispatch(actions.checkForAutoLogIn())}
    }
}
export default connect(mapStatetoProps, mapDispatchToProps)(Login);