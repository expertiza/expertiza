import React, { Component } from 'react';

class SuggestionsComponent extends Component {

render ( ) {

    return ( <div> In suggestion component with assignmen id: {this.props.match.params.id} </div>)
    }

}

export default SuggestionsComponent;