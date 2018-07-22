import React, {Component} from 'react';
import Aux from '../hoc/Aux/Aux'
import {NavLink} from 'react-router-dom';

class ChangeHandleComponent extends Component {

    state = {
        handle_name : ''
    }

    handleNameChangeHandler = (e) => {
        e.preventDefault();
        this.setState({handle_name: e.target.value});
    }
    render () {

        return (
            <div className="container">
                <form onSubmit={this.onSubmitHandler}>
                    <div style={{padding: '20px'}}>
                        <h1>Create or Change Handle for Current Assignment</h1>
                    </div>
                    {/* <%= form_tag({:action => 'change_handle', :id =>  @participant}) do %> */}
                    <p>Your <strong>handle</strong> is the way you will be known to your reviewers.</p>
                    <p>For example, if you are writing on a wiki, you might not want to use your Expertiza user-ID to show up on the
                    wiki, because then your reviewers would know who they are reviewing. So, you are allowed to set up a handle instead.
                    If you have a handle, then your wiki account is named after your handle, and your reviewers see your handle,
                    but not your user-ID.</p>
                    <p>If you do not have a handle, your user-ID will be used instead.</p>
                    
                    <p>You can set up a handle in two ways:
                        <ol><li>You can set up a handle for <em>only this assignment</em> by entering a handle below.</li>
                            <li>You can set up a "default" handle by editing your <NavLink to='/profile' >profile </NavLink></li>
                        </ol>
                        Note that if you change your handle by editing your <NavLink to='/profile' >profile </NavLink>, your new handle will be used for all <em>future</em> assignments;
                        if you want the change to apply to this assignment too, you must also change it below.
                    </p>
                    <p>Change handle <em>for current assignment</em>:</p>
                    <div className="form-group">
                        <input className="form-control" value={this.state.handle_name} onChange={this.handleNameChangeHandler}/>
                    </div>
                    <p><em>Warning:</em> You must have a wiki account named after your handle.  If you do not, please e-mail your instructor or the course staff.</p>
                    <div style={{ marginTop: '20px'}}>
                        <button type="submit" className="btn btn-success">Save</button>
                    </div>
                </form>
            </div>
        )
    }
}


export default ChangeHandleComponent;