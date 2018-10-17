// import React, { Component} from 'react';

// class SubmittedContentEditComponent extends Component {

//     render () {
//         return (
//             <div>
//                 <h3> In submitted Edit Component : {this.props.match.params.id} </h3>
//              </div>
//         )
//     }
// }

import React, {Component} from 'react';
import { connect } from 'react-redux'
import * as actions from '../../redux'
import { NavLink } from 'react-router-dom';
import Aux from '../../hoc/Aux/Aux'
import { Loading } from '../UI/spinner/LoadingComponent';
import { Alert } from 'reactstrap';
class SubmittedContentEditComponent extends Component {

    componentDidMount () {
        this.props.onSubmittedContentLoad(this.props.match.params.id);
        console.log(this.props.loaded);
    }


    render() {
        let loading;
        let submittedContent;
            if(this.props.loaded){
               submittedContent =  <div className="main_content">
               <h1>Submit work for {this.props.assignment.name}</h1>
                

                <NavLink to={`/studentlist`}>back</NavLink>   
            </div>
            }

            else{
                loading = <Loading/>
            }
            return (
                <Aux>
                    <div >
                        {loading}
                    </div>
                    <div>
                        {submittedContent}
                    </div>
                </Aux>
            )
    }
}

const mapStateToProps = state => {
    return {
        loaded: state.submittedContent.loaded,
        assignment: state.submittedContent.submitted_content.assignment
    }
}

const mapDispatchToProps = dispatch => {
    return {
        onSubmittedContentLoad: (id) => { dispatch(actions.onSubmittedContentLoad(id))}
    }
}
export default connect(mapStateToProps, mapDispatchToProps)(SubmittedContentEditComponent);

