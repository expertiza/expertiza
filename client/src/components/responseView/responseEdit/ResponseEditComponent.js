
import { Editor } from '@tinymce/tinymce-react';
import React, {Component} from 'react'
import {connect} from 'react-redux'
import * as actions from '../../../redux'
import {Loading} from '../../UI/spinner/LoadingComponent';
import StarRatings from 'react-star-ratings';

// class ResponseEditComponent = (props) => {
//     return ( 
//         <div>
//             <h3> In ResponseEditComponent {props.match.params.id}</h3>
//             <Editor
//                 init={{ plugins: "codesample, media"}}
//             />
//         </div>
//     )
// }

class ResponseEditComponent extends Component {
    componentDidMount () {
        this.props.fetchEditData(this.props.match.params.id)
    } 
    
    render() {
          if(!this.props.loading){
                return(
                <div>
                <h1>Edit Teammate Review for {this.props.assignment.name}</h1>
                {this.props.questions.map((question, index) =>
                    <div>
                        
                        <label>{question.txt}</label><br/>
                        <StarRatings
                            rating={this.props.review_scores[index].answer}
                            starRatedColor="brown"
                            // changeRating={this.changeRating}
                            numberOfStars={5}
                            name='rating'
                            starDimension="20px"
                            starSpacing="5px"
                        /><br/>
                        <Editor
                        initialValue = {this.props.review_scores[index].comments}
                        init={{ plugins: "codesample, media"}}
                        /><br/>
                    </div>
                ) }
                </div>
                )
            }

            else{
                return(
                    <div>
                        <Loading />
                    </div> 
                )
            }
        
       

    }              
            
}

const mapStatetoProps = state => {
    return {
        questions: state.responseReducer.questions,
        review_scores: state.responseReducer.review_scores,
        assignment: state.responseReducer.assignment,
        loading: state.responseReducer.loading

    }
}

const mapDispatchToProps = dispatch => {
    return {
        fetchEditData : id => dispatch(actions.fetchEditData(id))
    }
}

export default connect(mapStatetoProps, mapDispatchToProps)(ResponseEditComponent);