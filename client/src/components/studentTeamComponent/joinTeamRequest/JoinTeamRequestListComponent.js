import React from 'react'
import JoinTeamRequestHelper from './joinTeamRequestHelper/JoinTeamRequestHelper'
import Aux from '../../../hoc/Aux/Aux'
import '../../../assets/stylesheets/goldberg.css'

const joinTeamRequestListComponent = (props) => {
    let output;
    console.log('in Join team request list component value of join_team_requests',props.join_team_requests,Array.isArray(props.join_team_requests))
    if( Array.isArray(props.join_team_requests) && props.join_team_requests.length !== 0 ) {
        output = 
            <div className="container-fluid">
                <h2>Received Requests</h2>
                <table style={{width:"80%", align:"center"}} >
                    <tr style={{ border: "1px outset #000000; "}}>
                        <th className="head">Name</th>
                        <th className="head">Comments</th>
                        <th className="head">Action</th>
                        <th className="head">Sent at</th>
                    </tr>
                    { props.join_team_requests.map( join_team_request => {
                        if(join_team_request.status === 'P') {
                           return  <JoinTeamRequestHelper join_team_request={join_team_request} />
                        }
                    })}
                </table>
            </div> 
    }

    return <Aux> {output} </Aux>;

}

export default joinTeamRequestListComponent;