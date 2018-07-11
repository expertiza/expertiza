import { Navbar, NavbarBrand, Nav, NavbarToggler, Collapse, NavItem,
    Button } from 'reactstrap';
import { NavLink } from 'react-router-dom';
import React, { Component } from 'react';

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
                            <Nav navbar>
                                <NavItem>
                                    <NavLink className="nav-link" to="/home">Home </NavLink>
                                </NavItem>
                                <NavItem>
                                     <NavLink className="nav-link" to="/home">
                                         Assignments
                                     </NavLink>
                                </NavItem>     
                                <NavItem>
                                    <NavLink className="nav-link" to="/home" >
                                        Pending Surveys 
                                     </NavLink>
                                </NavItem>
                                <NavItem>
                                    <NavLink className="nav-link" to="/profile">
                                        Profile 
                                    </NavLink> 
                                </NavItem>
                                <NavItem>
                                    <NavLink className="nav-link" to="/home">
                                        Contact Us
                                    </NavLink>
                                </NavItem>
                            </Nav>
                            <Nav className="ml-auto" navbar>
                                {/* <NavItem>
                                    <Button outline> Login</Button>
                                </NavItem> */}
                                <NavLink className="nav-link" to="/login">Login </NavLink>
                            </Nav>
                        </Collapse>
                </Navbar>
        </div>
        );
    }
}
export default Header;