import React, { Component } from 'react';

class Header extends Component {
    constructor(props) {
        super(props);
    }

    render(){
        return(
                <div className="footer" align="center">
                   <span className="navigationSpace"> <a href="http://wiki.expertiza.ncsu.edu/index.php/Expertiza_documentation" target='_blank' rel="noopener noreferrer">Help</a></span>
                    <span className="navigationSpace"><a href="http://research.csc.ncsu.edu/efg/expertiza/papers" target='_blank' rel="noopener noreferrer"> Papers on Expertiza</a></span>
                </div>
        );
    }
}
export default Header;