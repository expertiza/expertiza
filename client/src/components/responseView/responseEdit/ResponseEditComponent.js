import React from 'react';

const ResponseEditComponent = (props) => {
    return ( 
        <div>
            <h3> In ResponseEditComponent {props.match.params.id}</h3>
        </div>
    )
}

export default ResponseEditComponent;