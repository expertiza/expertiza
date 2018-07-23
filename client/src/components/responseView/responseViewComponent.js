import React from 'react';

const responseViewComponent = (props) => {

    return (
        <div> In response View Component = {props.match.params.id} </div>
    )
}

export default responseViewComponent;