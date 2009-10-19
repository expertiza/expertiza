class ReviewFeedbackController < ApplicationController
    # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }
         
  def new
    @review = Review.find(params[:id])    
    questionnaire = Questionnaire.find(@review.review_mapping.assignment.author_feedback_questionnaire_id)
    @questions = Question.find_all_by_questionnaire_id(questionnaire.id)
    @min = questionnaire.min_question_score
    @max = questionnaire.max_question_score
  end
  
  def create
    review = Review.find(params[:id])
    mapping = review.review_mapping
    questionnaire = Questionnaire.find(review.review_mapping.assignment.author_feedback_questionnaire_id)
    questions = Question.find_all_by_questionnaire_id(questionnaire.id)     
     
    participant = AssignmentParticipant.find_by_user_id_and_parent_id(session[:user].id, mapping.assignment.id)
     
    if review.nil?
      flash[:error] = "No review has been performed."
    else
      @feedback = ReviewFeedback.create(:assignment_id => mapping.assignment.id, :review_id => review.id,
                                        :additional_comment => params[:review][:comments], :author_id => session[:user].id);
      if mapping.assignment.team_assignment
        @feedback.team_id = mapping.team_id
        @feedback.save
      end
        
      params[:responses].each_pair do |k,v|
        score = Score.create(:instance_id => @feedback.id, :question_id => questions[k.to_i].id,
                             :questionnaire_type_id => questionnaire.type_id, :score => v[:score], :comments => v[:comment])
      end          
            
    #determine if the new review meets the criteria set by the instructor's 
    #notification limits      
      compare_scores
    end
      
    redirect_to :controller => 'student_assignment', :action => 'view_scores', :id => participant.id
  end
  
  def edit
    @feedback = ReviewFeedback.find(params[:id])
    questionnaire = Questionnaire.find(@feedback.assignment.author_feedback_questionnaire_id)
    @questions = Question.find_all_by_questionnaire_id(questionnaire.id)
    @review_scores = Score.find_all_by_instance_id_and_questionnaire_type_id(@feedback.id, questionnaire.type_id)
    @min = questionnaire.min_question_score
    @max = questionnaire.max_question_score    
  end 
  
  def update
    @feedback = ReviewFeedback.find(params[:id])
    @feedback.additional_comment = params[:review][:comments]
    @feedback.save
    
    participant = AssignmentParticipant.find_by_user_id_and_parent_id(@feedback.author_id,@feedback.assignment.id)
    questionnaire = Questionnaire.find(@feedback.assignment.author_feedback_questionnaire_id)
    questions = Question.find_all_by_questionnaire_id(questionnaire.id)

    params[:responses].each_pair do |k,v|
      score = Score.find_by_instance_id_and_question_id_and_questionnaire_type_id(@feedback.id, questions[k.to_i].id,questionnaire.type_id)
      score.score = v[:score]
      score.comments = v[:comment]
      score.save
    end    
    
    #determine if the new review meets the criteria set by the instructor's 
    #notification limits      
    compare_scores
    
    redirect_to :controller => 'student_assignment', :action => 'view_scores', :id => participant.id
  end
  
  def view
    @feedback = ReviewFeedback.find(params[:id])
    questionnaire = Questionnaire.find(@feedback.assignment.author_feedback_questionnaire_id)
    @questions = Question.find_all_by_questionnaire_id(questionnaire.id)
    @review_scores = Score.find_all_by_instance_id_and_questionnaire_type_id(@feedback.id, questionnaire.type_id)    
  end
  
  # Compute the currently awarded scores for the reviewee
  # If the new review's score is greater than or less than 
  # the existing scores by a given percentage (defined by
  # the instructor) then notify the instructor.
  # ajbudlon, nov 18, 2008
  def compare_scores  
    if @feedback.assignment.team_assignment 
      participant = AssignmentTeam.find(@feedback.team_id)
    else
      participant = AssignmentParticipant.find_by_user_id_and_parent_id(@feedback.author_id,@feedback.assignment.id)      
    end          
    total, count = ReviewHelper.get_total_scores(participant.get_feedbacks,@feedback)     
    if count > 0
      questionnaire = Questionnaire.find(@feedback.assignment.author_feedback_questionnaire_id)
      ReviewHelper.notify_instructor(@feedback.assignment,@feedback,questionnaire,total,count)
    end
  end  
  
end
