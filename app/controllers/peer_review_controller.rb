class PeerReviewController < ApplicationController
  
  def new
    @reviewer = User.find_by_id(params[:reviewer_id])
    @reviewee = User.find_by_id(params[:reviewee_id])
    #@team = Team.find_by_id(params[:team_id])
    @assgt = Assignment.find_by_id(params[:assignment_id])
    
    @student = Participant.find(:first, :conditions => ['user_id =? and parent_id =?', @reviewer.id, @assgt.id])
  
    @questions = Question.find(:all,:conditions => ["questionnaire_id = ?", @assgt.peer_review_questionnaire_id]) 
    @questionnaire = Questionnaire.find(@assgt.peer_review_questionnaire_id)
    @max = @questionnaire.max_question_score
    @min = @questionnaire.min_question_score
  end
  
  def create
    @peer_review = PeerReview.new 
    @peer_review.reviewer_id = params[:reviewer_id]
    @peer_review.reviewee_id = params[:reviewee_id]
    @peer_review.assignment_id = params[:assgt_id]
    #@peer_review.team_id = params[:team_id]
    @peer_review.additional_comment = params[:new_peer_review][:comments]
    if params[:new_peer_review_score]
      # The new_question array contains all the new questions
      # that should be saved to the database
      for peer_review_key in params[:new_peer_review_score].keys
        prs = PeerReviewScore.new(params[:new_peer_review_score][peer_review_key])
        prs.question_id = params[:new_question][peer_review_key]
        prs.score = params[:new_score][peer_review_key]
        @peer_review.peer_review_scores << prs
      end      
    end
    if @peer_review.save
      flash[:notice] = 'Peer review was successfully saved.'
      @student = Participant.find(:first, :conditions => ['user_id =? and parent_id =?', @peer_review.reviewer_id, @peer_review.assignment_id])
      redirect_to :controller => 'student_assignment', :action => 'view_team', :id => @student.id
    else # If something goes wrong, stay at same page
      render :action => 'new', :reviewer_id => @peer_review.reviewer_id, 
                               :reviewer_id => @peer_review.reviewer_id, 
                               :reviewee_id => @peer_review.reviewee_id,  
                               :assignment_id => @peer_review.assignemnt_id 
                               #:team_id => @peer_review.team_id       
    end
  end

  def view
    #@links,@review,@mapping_id,@review_scores,@mapping,@assgt,@author,@questions,@questionnaire,@author_first_user_id,@team_members,@author_name,@max,@min,@current_folder,@files,@direc = ReviewController.process_review(params[:id],params[:current_folder])
    @peer_review_id=params[:id]
    @peer_review = PeerReview.find_by_id(@peer_review_id)
    @student = Participant.find(:first, :conditions => ['user_id =? and parent_id =?', @peer_review.reviewer_id, @peer_review.assignment_id])
    @peer_review_scores = PeerReviewScore.find(:all,:conditions =>["peer_review_id =?", @peer_review_id])
  end
  
  def edit
    #@links,@review,@mapping_id,@review_scores,@mapping,@assgt,@author,@questions,@questionnaire,@author_first_user_id,@team_members,@author_name,@max,@min,@current_folder,@files,@direc = ReviewController.process_review(params[:id],params[:current_folder])
    @peer_review_id=params[:id]
    @peer_review = PeerReview.find_by_id(@peer_review_id)
    @student = Participant.find(:first, :conditions => ['user_id =? and parent_id =?', @peer_review.reviewer_id, @peer_review.assignment_id])
    @assignment = Assignment.find_by_id( @peer_review.assignment_id)
    @questionnaire = Questionnaire.find(@assignment.peer_review_questionnaire_id)
    @questions = Question.find(:all,:conditions => ["questionnaire_id = ?", @questionnaire.id]) 
    @max = @questionnaire.max_question_score
    @min = @questionnaire.min_question_score 
    #@peer_review_scores = PeerReviewScore.find(:all,:conditions =>["peer_review_id =?", @peer_review_id])
  end
 
  def update  
    @peer_review = PeerReview.find(params[:peer_review_id])
    @peer_review.additional_comment = params[:new_peer_review][:comments]
    if params[:new_peer_review_score]
      # The new_question array contains all the new questions
      # that should be saved to the database
      for peer_review_key in params[:new_peer_review_score].keys
        question_id = params[:new_question][peer_review_key]
        prs = PeerReviewScore.find(:first,:conditions => ["peer_review_id = ? AND question_id = ?", @peer_review.id, question_id])
        prs.comments = params[:new_peer_review_score][peer_review_key][:comments]
        prs.score = params[:new_score][peer_review_key]
        prs.update
      end      
    end
    if @peer_review.update
      flash[:notice] = 'Peer review was successfully saved.'
      @student = Participant.find(:first, :conditions => ['user_id =? and parent_id =?', @peer_review.reviewer_id, @peer_review.assignment_id])
      redirect_to :controller => 'student_assignment', :action => 'view_team', :id => @student.id
    else # If something goes wrong, stay at same page
      render :action => 'edit', :id => @peer_review.id
    end
  end
  
end