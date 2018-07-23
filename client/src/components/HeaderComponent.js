import { Navbar, NavbarBrand, Nav, NavbarToggler, Collapse, NavItem } from 'reactstrap';
import { NavLink } from 'react-router-dom';
import React, { Component } from 'react';
import {connect} from 'react-redux'

class Header extends Component {
    constructor(props) {
        super(props);
        this.toggleNav = this.toggleNav.bind(this);   
        this.state = {
            isNavOpen: false,
        };
    }
    toggleNav(){
        this.setState({
            isNavOpen : !this.state.isNavOpen
        });
    }
    render(){
        return(
            <div>
                <Navbar dark expand="md">
                        <NavbarToggler onClick={this.toggleNav} />
                        <NavbarBrand className="ml-0" href="/"><img src='assets/images/logo.png' height="65" width="143" alt='Expertiza' /></NavbarBrand>
                        <Collapse isOpen={this.state.isNavOpen} navbar>
                            {this.props.loggedIn ?  <Nav navbar>
                                <NavItem>
                                    <NavLink className="nav-link" to="/home">Home </NavLink>
                                </NavItem>
                                <NavItem>
                                     <NavLink className="nav-link" to="/studentlist"> Assignments </NavLink>
                                </NavItem>     
                                <NavItem>
                                    <NavLink className="nav-link" to="/home" > Pending Surveys  </NavLink>
                                </NavItem>
                                <NavItem>
                                    <NavLink className="nav-link" to="/profile"> Profile  </NavLink> 
                                </NavItem>
                                <NavItem>
                                    <NavLink className="nav-link" to="/home"> Contact Us </NavLink>
                                </NavItem>
                            </Nav> : null}
                            <Nav className="ml-auto" navbar>
                                { this.props.loggedIn ? <NavLink className="nav-link" to="/logout">Log out </NavLink> : null }
                            </Nav>
                        </Collapse>
                </Navbar>
        </div>
        );
    }
}

const mapStateToProps = state => {
    return {
        loggedIn: state.auth.loggedIn
    }
}
export default connect( mapStateToProps)(Header);