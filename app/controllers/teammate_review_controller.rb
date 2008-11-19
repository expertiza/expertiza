class TeammateReviewController < ApplicationController
  
  def new
    @reviewer = session[:user]
    @reviewee = User.find(params[:reviewee_id])
    @assgt = Assignment.find(params[:assignment_id])
    
    @student = AssignmentParticipant.find(:first, :conditions => ['user_id =? and parent_id =?', @reviewer.id, @assgt.id])
  
    @questions = Question.find(:all,:conditions => ["questionnaire_id = ?", @assgt.teammate_review_questionnaire_id]) 
    @questionnaire = Questionnaire.find(@assgt.teammate_review_questionnaire_id)
    @max = @questionnaire.max_question_score
    @min = @questionnaire.min_question_score
  end
  
  def create
    @teammate_review = TeammateReview.new 
    @teammate_review.reviewer_id = params[:reviewer_id]
    @teammate_review.reviewee_id = params[:reviewee_id]
    @teammate_review.assignment_id = params[:assgt_id]
    #@teammate_review.team_id = params[:team_id]
    @teammate_review.additional_comment = params[:new_teammate_review][:comments]
    if @teammate_review.save
      if params[:new_teammate_review_score]
        # The new_question array contains all the new questions
        # that should be saved to the database
        latest_teammate_review_id = TeammateReview.find_by_sql ("select max(id) as id from teammate_reviews")[0].id
        for teammate_review_key in params[:new_teammate_review_score].keys
          prs = Score.new(params[:new_teammate_review_score][teammate_review_key])
          prs.question_id = params[:new_question][teammate_review_key]
          prs.instance_id = latest_teammate_review_id
          prs.questionnaire_type_id = QuestionnaireType.find_by_name("Teammate Review").id
          prs.score = params[:new_score][teammate_review_key]
          prs.save
        end      
      end
      compare_scores
      flash[:notice] = 'Teammate review was successfully saved.'
      @student = Participant.find(:first, :conditions => ['user_id =? and parent_id =?', @teammate_review.reviewer_id, @teammate_review.assignment_id])
      redirect_to :controller => 'student_team', :action => 'view', :id => @student.id
    else # If something goes wrong, stay at same page
      render :action => 'new', :reviewer_id => @teammate_review.reviewer_id, 
                               :reviewer_id => @teammate_review.reviewer_id, 
                               :reviewee_id => @teammate_review.reviewee_id,  
                               :assignment_id => @teammate_review.assignemnt_id 
                               #:team_id => @teammate_review.team_id       
    end
  end
  
  # Compute the currently awarded scores for the reviewee
  # If the new teammate review's score is greater than or less than 
  # the existing scores by a given percentage (defined by
  # the instructor) then notify the instructor.
  # ajbudlon, nov 18, 2008
  def compare_scores      
    participant = AssignmentParticipant.find_by_user_id_and_parent_id(@teammate_review.reviewer_id,@assignment.id)                    
    total, count = ReviewHelper.get_total_scores(participant.get_teammate_reviews,@teammate_review)     
    if count > 0
      questionnaire = Questionnaire.find(@assignment.teammate_review_questionnaire_id)
      ReviewHelper.notify_instructor(@assignment,questionnaire)
    end
  end 

  def view
    #@links,@review,@mapping_id,@review_scores,@mapping,@assgt,@author,@questions,@questionnaire,@author_first_user_id,@team_members,@author_name,@max,@min,@files,@direc = ReviewController.show_review(params[:id])
    @teammate_review_id=params[:id]
    @teammate_review = TeammateReview.find_by_id(@teammate_review_id)
    @student = Participant.find(:first, :conditions => ['user_id =? and parent_id =?', @teammate_review.reviewer_id, @teammate_review.assignment_id])
    @teammate_review_scores = Score.find(:all,:conditions =>["instance_id =? and questionnaire_type_id=?", @teammate_review_id, QuestionnaireType.find_by_name("Teammate Review").id])
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
    if @teammate_review.update
      flash[:notice] = 'Teammate review was successfully saved.'
      @student = Participant.find(:first, :conditions => ['user_id =? and parent_id =?', @teammate_review.reviewer_id, @teammate_review.assignment_id])
      redirect_to :controller => 'student_team', :action => 'view', :id => @student.id
    else # If something goes wrong, stay at same page
      render :action => 'edit', :id => @teammate_review.id
    end
  end
  
end