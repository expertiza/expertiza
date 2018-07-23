import React, { Component } from 'react';


class SignupSheet extends Component {
    // constructor(props) {
    //     super(props);
    // }
    render(){
        return(
            <div className="main_content">
                <h1>Signup sheet for Final Project (and design doc) assignment</h1>
                <br></br>
                <b>Your topic(s):</b>
                <br></br>
                
                <br></br>
                <br></br>

                <table class="general">
                    <tbody>
                        <tr>
                            <th width="5%">Topic #</th> 
                            <th width="50%">Topic name(s)</th>
                            <th width="5%">Num. of slots</th>
                            <th width="5%">Available slots</th>
                            <th width="5%">Num. on waitlist</th>
                            <th width="10%">Bookmarks</th>
                        </tr>
                    </tbody>
                </table>    
            </div>
        );
    }
}
export default SignupSheet;