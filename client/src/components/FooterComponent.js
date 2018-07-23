import React, { Component } from 'react';

class Header extends Component {
    // constructor(props) {
    //     super(props);
    // }

    render(){
        return(
                <div className="footer" align="center">
                   <span className="navigationSpace"> <a href="http://wiki.expertiza.ncsu.edu/index.php/Expertiza_documentation" target='_blank' rel="noopener noreferrer">Help</a></span>
                   <span className="navigationSpace"><a href="https://www.youtube.com/watch?v=CaUOA2WLsOY&list=PLfg44kGPNXFMb72Wnb9BD81h3HHYZDvjJ" target='_blank' rel="noopener noreferrer">Expertiza Youtube</a></span>
                </div>
        );
    }
}
export default Header;