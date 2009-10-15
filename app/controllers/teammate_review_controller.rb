class TeammateReviewController < ApplicationController
  helper :review
  
  def new
    reviewer = AssignmentParticipant.find(params[:id])
    reviewee = AssignmentParticipant.find(params[:reviewee_id])
    @map = TeammateReviewMapping.create(:reviewer_id => reviewer.id, :reviewee_id => reviewee.id, :reviewed_object_id => reviewer.assignment.id)
    @questionnaire = Questionnaire.find(@map.assignment.teammate_review_questionnaire_id)
    @questions = @questionnaire.questions
    @max = @questionnaire.max_question_score
    @min = @questionnaire.min_question_score
  end
  
  def create
    map = TeammateReviewMapping.find(params[:id])
    @teammate_review = TeammateReview.create(:mapping_id => map.id)
    @assignment = map.assignment
    @teammate_review.additional_comment = params[:new_teammate_review][:comments]
    if @teammate_review.save
      if params[:new_teammate_review_score]
        # The new_question array contains all the new questions
        # that should be saved to the database
        for teammate_review_key in params[:new_teammate_review_score].keys
          Score.create(:question_id => params[:new_question][teammate_review_key],
                       :instance_id => @teammate_review.id,
                       :questionnaire_type_id => QuestionnaireType.find_by_name("Teammate Review").id,
                       :score => params[:new_score][teammate_review_key],
                       :comments => params[:new_teammate_review_score][teammate_review_key][:comments])
                       
        end      
      end
      compare_scores
      flash[:note] = 'Teammate review was successfully saved.'
      redirect_to :controller => 'student_team', :action => 'view', :id => map.reviewer.id
    else # If something goes wrong, stay at same page      
      flash[:error] = 'Teammate review was not saved.' 
      redirect_to :controller => 'student_team', :action => 'view', :id => map.reviewer.id    
    end
  end
  
  # Compute the currently awarded scores for the reviewee
  # If the new teammate review's score is greater than or less than 
  # the existing scores by a given percentage (defined by
  # the instructor) then notify the instructor.
  # ajbudlon, nov 18, 2008
  def compare_scores      
    participant = @teammate_review.mapping.reviewer                    
    total, count = ReviewHelper.get_total_scores(participant.get_teammate_reviews,@teammate_review)     
    if count > 0
      questionnaire = Questionnaire.find(@assignment.teammate_review_questionnaire_id)
      ReviewHelper.notify_instructor(@assignment,@teammate_review,questionnaire,total,count)
    end
  end 

  def view
    @teammate_review = TeammateReview.find_by_id(params[:id])
    @student = @teammate_review.mapping.reviewer 
    @teammate_review_scores = Score.find(:all,:conditions =>["instance_id =? and questionnaire_type_id=?", @teammate_review.id, QuestionnaireType.find_by_name("Teammate Review").id])
  end
  
  def edit
    #@links,@review,@mapping_id,@review_scores,@mapping,@assgt,@author,@questions,@questionnaire,@author_first_user_id,@team_members,@author_name,@max,@min,@files,@direc = ReviewController.show_review(params[:id])
    @teammate_review_id=params[:id]
    @teammate_review = TeammateReview.find_by_id(@teammate_review_id)
    @student = Participant.find(:first, :conditions => ['user_id =? and parent_id =?', @teammate_review.reviewer_id, @teammate_review.assignment_id])
    @assignment = Assignment.find_by_id( @teammate_review.assignment_id)
    @questionnaire = Questionnaire.find(@assignment.teammate_review_questionnaire_id)
    @questions = Question.find(:all,:conditions => ["questionnaire_id = ?", @questionnaire.id]) 
    @max = @questionnaire.max_question_score
    @min = @questionnaire.min_question_score 
    #@teammate_review_scores = Score.find(:all,:conditions =>["instance_id =? and questionnaire_type_id=?", @teammate_review_id, QuestionnaireType.find_by_name("Teammate Review").id])
  end
 
  def update  
    @teammate_review = TeammateReview.find(params[:teammate_review_id])
    @teammate_review.additional_comment = params[:new_teammate_review][:comments]
    if params[:new_teammate_review_score]
      # The new_question array contains all the new questions
      # that should be saved to the database
      for teammate_review_key in params[:new_teammate_review_score].keys
        question_id = params[:new_question][teammate_review_key]
        prs = Score.find(:first,:conditions => ["instance_id = ? AND question_id = ? and questionnaire_type_id=?", @teammate_review.id, question_id, QuestionnaireType.find_by_name("Teammate Review").id])
        prs.comments = params[:new_teammate_review_score][teammate_review_key][:comments]
        prs.score = params[:new_score][teammate_review_key]
        prs.update
      end      
    end
    @assignment = Assignment.find(@teammate_review.assignment_id)
    if @teammate_review.update
      compare_scores
      flash[:notice] = 'Teammate review was successfully saved.'
      @student = Participant.find(:first, :conditions => ['user_id =? and parent_id =?', @teammate_review.reviewer_id, @teammate_review.assignment_id])
      redirect_to :controller => 'student_team', :action => 'view', :id => @student.id
    else # If something goes wrong, stay at same page
      render :action => 'edit', :id => @teammate_review.id
    end
  end
  
end