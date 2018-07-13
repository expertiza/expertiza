import React from 'react';

const PasswordForgotten = (props) => {
    
    const onEmailChangeHandler = (e) => {
        console.log(e.target.value)
    }

    return (
        <div className="container" style={{marginTop: '10px'}}>
            <div className="row">
                <div className="col-md-6">
                <h4>Forgotten Your Password?</h4>
                <div className="row">
                    <div className="form-group">
                        <label >Enter the e-mail address associated with your account:</label>
                        <input onChange={onEmailChangeHandler} className="form-control" id="usr" />
                    </div>
                </div>
                
                <div className="row">
                    <button type="submit" className="btn btn-danger">Submit</button>
                </div>
                </div>
            </div>
        </div>
    )
}


export default PasswordForgotten;