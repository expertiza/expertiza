import * as actions from '../index'

const initialize={
    review_mappings: null,
    candidate_topics_to_review:[],
    num_reviews_in_progress: null,
    candidate_reviews_started: [],
}

const  assignmentReviewData= (state = initialize, action) => {
switch(action.type){
   case actions.ADD_ASSIGNMENT_REVIEW_DATA:
        return {...state,
                candidate_reviews_started: action.payload.candidate_reviews_started,
                candidate_topics_to_review: action.payload.candidate_topics_to_review,
                num_reviews_in_progress: action.payload.num_reviews_in_progress,
                non_reviewable_topics: action.payload.non_reviewable_topics,
                candidate_topics_to_review: action.payload.candidate_topics_to_review
        };
   default: 
       return state;
}
};

export default assignmentReviewData;