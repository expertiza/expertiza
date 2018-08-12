import React, {Component} from 'react'
import {connect} from 'react-redux'

import {Loading} from '../UI/spinner/LoadingComponent';
import * as actions from '../../redux/index'


class  ResponseViewComponent extends Component {

    
    componentDidMount () {
        this.props.fetchReviewData(this.props.match.params.id)
    }    

    render () {
        let title;
        if(!this.props.loading) {
            if ( this.props.survey ) {
                title = <h1> {this.props.title} for  {this.props.survey_parent.name} </h1>
    
            }
            else {
                title = <h1> {this.props.title} for {this.props.assignment.name}</h1>
            }
        }
         
            
        return (
            <div>
                {this.props.loading ? <Loading /> : title}
            </div>
        )
    }
    
}


const mapStatetoProps = state => {
    return {
        map: state.responseReducer.map,
        survey: state.responseReducer.survey,
        survey_parent: state.responseReducer.survey_parent,
        title: state.responseReducer.title,
        assignment: state.responseReducer.assignment,
        loading: state.responseReducer.loading
    }
}

const mapDispatchToProps = dispatch => {
    return {
        fetchReviewData : review_id => dispatch(actions.fetchReviewData(review_id))
    }
}
export default connect(mapStatetoProps, mapDispatchToProps)(ResponseViewComponent);