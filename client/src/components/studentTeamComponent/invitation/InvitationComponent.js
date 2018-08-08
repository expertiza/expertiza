import React,{Component} from 'react';
import Aux from '../../../hoc/Aux/Aux'
import {NavLink} from 'react-router-dom'
import {connect} from 'react-redux'
import * as actions from '../../../redux/index'

class invitationComponent extends Component {
    
    
    render () {
        let output;
        if (this.props.inv.reply_status === 'A') {
            output = <td align = "center">Accepted</td>
        } else if (this.props.inv.reply_status === 'D') {
            output = <td align = "center">Declined</td>
        } else {
            output = <td align = "center">Waiting for reply
                        &nbsp;&nbsp;
                        <NavLink  to="#" onClick={() => this.props.retractInvitation(this.props.inv.id, this.props.student.id)}>Retract</NavLink> 
                    </td> 
        }

        return (
            <Aux>
                <tr>
                    <td> {this.props.inv.to_user.name} </td>
                    <td> {this.props.inv.to_user.fullname} </td>
                    <td> {this.props.inv.to_user.email} </td>
                    {output}        
                </tr>
            </Aux>
        )
    }
    
    
}
const mapDispatchToProps = dispatch => {
    return {
        retractInvitation : ( inv_id, student_id) => dispatch(actions.retractInvitation(inv_id, student_id))
    }
}
export default connect(null, mapDispatchToProps)(invitationComponent);