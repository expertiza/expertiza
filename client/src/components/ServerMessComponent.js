import React from 'react';
import { Card, CardTitle} from 'reactstrap';


const SuccessCard = () => {
    return (
                <Card>
                    <CardTitle>Update Successfull</CardTitle>
                </Card>    
    );
}



const ErrorCard = () => {
    return (
                <Card>
                    <CardTitle>There was an error, Please try again!!</CardTitle>
                </Card>    
    );
}

const ServerMessage = (props) => {

    if(props.err === null)
    {
            return (
                <div className = "container">
                    <div className = "row">     
                    </div>
                </div>
            );
    }
    else {
        return(
            <div className = "container">
                <div className = "row">     
                    <SuccessCard />
                </div>
            </div>
        );
    }
}
export default ServerMessage;