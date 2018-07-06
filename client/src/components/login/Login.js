import React, { Component} from 'react';

class Login extends Component {
    state = {
        email: '',
        password: ''
    }

    onSubmitHandler = (event) => {
        event.preventDefault();
        console.log(event);
    }
    emailChangeHandler = (event) => {
        console.log(event.target.value)
        this.setState({email: event.target.value})
    }

    passwordChangeHandler = (event) => {
        console.log(event.target.value)
        this.setState({password: event.target.value})
    }

    render (){
        return (
            <div className="container center" style= {{marginTop:'35px'}}>
                <div className="row">
                    <div className="col-md-6 col-md-offset-6">
                        <form onSubmit={this.onSubmitHandler}>
                            <div className="form-group">
                                <label >Email address</label>
                                <input type="email" 
                                        className="form-control" 
                                        placeholder="Enter email" 
                                        value={this.state.email}
                                        onChange={this.emailChangeHandler}
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
                            <button type="submit" className="btn btn-primary">Submit</button>
                        </form>
                </div>
            </div> 
        </div>
        )
    }
}
export default Login;