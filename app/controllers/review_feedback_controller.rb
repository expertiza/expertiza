class ReviewFeedbackController < ApplicationController
    # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }
         
  def new
    review = Review.find(params[:id]) 
    reviewer = AssignmentParticipant.find_by_user_id_and_parent_id(session[:user].id, review.review_mapping.assignment.id)
    reviewee = AssignmentParticipant.find_by_user_id_and_parent_id(review.review_mapping.reviewer.id, review.review_mapping.assignment.id)
    @mapping = FeedbackMapping.create(:reviewed_object_id => review.id, :reviewer_id => reviewer.id, :reviewee_id => reviewee.id)
    @questionnaire = Questionnaire.find(@mapping.assignment.author_feedback_questionnaire_id)
    @questions = @questionnaire.questions
    @min = @questionnaire.min_question_score
    @max = @questionnaire.max_question_score
  end
  
  def create
    map = FeedbackMapping.find(params[:id])
    @response = ReviewFeedback.create(:mapping_id => map.id, :additional_comment => params[:review][:comments])
    @questionnaire = Questionnaire.find(map.assignment.author_feedback_questionnaire_id)
    questions = @questionnaire.questions     
    
    params[:responses].each_pair do |k,v|
      score = Score.create(:instance_id => @response.id, :question_id => questions[k.to_i].id,
                           :questionnaire_type_id => @questionnaire.type_id, :score => v[:score], :comments => v[:comment])
    end      
    
    compare_scores
    flash[:note] = 'Feedback was successfully saved.'
    redirect_to :controller => 'student_assignment', :action => 'view_scores', :id => map.reviewer.id
  end
  
  def view
    @response = ReviewFeedback.find(params[:id])
  end
  
  def edit
    @response = ReviewFeedback.find(params[:id]) 
    @mapping = @response.mapping
    @questionnaire = Questionnaire.find(@response.mapping.assignment.author_feedback_questionnaire_id)
    @questions = @questionnaire.questions
    @review_scores = Score.find_all_by_instance_id_and_questionnaire_type_id(@response.id, @questionnaire.type_id)
    @min = @questionnaire.min_question_score
    @max = @questionnaire.max_question_score    
  end 
  
  def update
    map = FeedbackMapping.find(params[:id])
    @response = ReviewFeedback.find_by_mapping_id(map.id)
    @response.additional_comment = params[:review][:comments]
    @response.save
    
    @questionnaire = Questionnaire.find(@response.mapping.assignment.author_feedback_questionnaire_id)
    questions = @questionnaire.questions

    params[:responses].each_pair do |k,v|
      score = Score.find_by_instance_id_and_question_id_and_questionnaire_type_id(@response.id, questions[k.to_i].id, @questionnaire.type_id)
      score.score = v[:score]
      score.comments = v[:comment]
      score.save
    end    
    
    #determine if the new review meets the criteria set by the instructor's 
    #notification limits      
    compare_scores
    
    redirect_to :controller => 'student_assignment', :action => 'view_scores', :id => map.reviewer.id
  end
  
  # Compute the currently awarded scores for the reviewee
  # If the new review's score is greater than or less than 
  # the existing scores by a given percentage (defined by
  # the instructor) then notify the instructor.
  def compare_scores      
    participant = @response.mapping.reviewer                    
    total, count = ReviewHelper.get_total_scores(participant.get_teammate_reviews,@response)     
    if count > 0
      ReviewHelper.notify_instructor(@response.mapping.assignment,@response,@questionnaire,total,count)
    end
  end
  
end
