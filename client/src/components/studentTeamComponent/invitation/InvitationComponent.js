import React from 'react';
import Aux from '../../../hoc/Aux/Aux'
import {NavLink} from 'react-router-dom'

const invitationComponent = props => {
    let output;
     if (props.inv.reply_status === 'A') {
        output = <td align = "center">Accepted</td>
     } else if (props.inv.reply_status === 'D') {
        output = <td align = "center">Declined</td>
     } else {
        output = <td align = "center">Waiting for reply
                    &nbsp;&nbsp;
                    <NavLink  to="#">Retract</NavLink>
                </td> //{:controller => 'invitations', :action => 'cancel', :inv_id => inv.id, :student_id => @student.id} 
     }

    return (
        <Aux>
            <tr>
                <td> {props.inv.to_user.name} </td>
                <td> {props.inv.to_user.fullname} </td>
                <td> {props.inv.to_user.email} </td>
                {output}        
            </tr>
        </Aux>
    )
}
export default invitationComponent;