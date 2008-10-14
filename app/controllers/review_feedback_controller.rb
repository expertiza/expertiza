class ReviewFeedbackController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @review_feedback_pages, @review_feedbacks = paginate :review_feedbacks, :per_page => 10
  end

  def show
    @review_feedback = ReviewFeedback.find(params[:id])
  end

  def new
    @review_feedback = ReviewFeedback.new
  end

  def create
    @review_feedback = ReviewFeedback.new(params[:review_feedback])
    if @review_feedback.save
      flash[:notice] = 'ReviewFeedback was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @review_feedback = ReviewFeedback.find(params[:id])
  end

  def update
    @review_feedback = ReviewFeedback.find(params[:id])
    if @review_feedback.update_attributes(params[:review_feedback])
      flash[:notice] = 'ReviewFeedback was successfully updated.'
      redirect_to :action => 'show', :id => @review_feedback
    else
      render :action => 'edit'
    end
  end

  def destroy
    ReviewFeedback.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  # Action implemented for editing the feedback rubric already entered
  def edit_feedback
    @a = (params[:id3])
    @b = (params[:id2])
    @assignment = Assignment.find_by_id(params[:id1])
    if @assignment.team_assignment
    # Find entry in ReviewFeedback table with passed review id and author id
      @reviewfeedback = ReviewFeedback.find(:first, :conditions =>["review_id =? AND team_id = ?", @a, params[:id4]])
    else  
      @reviewfeedback = ReviewFeedback.find(:first, :conditions =>["review_id =? AND author_id = ?", @a, @b])
    end
    @assgt_id = params[:id1]
    @author_id = params[:id2]
    @review_id = params[:id3]
    @team_id = params[:id4]
    
    @assignment = Assignment.find(@assgt_id)
    @questions = Question.find(:all,:conditions => ["questionnaire_id = ?", @assignment.author_feedback_questionnaire_id]) 
    @rubric = Questionnaire.find(@assignment.author_feedback_questionnaire_id)
    @max = @rubric.max_question_score
    @min = @rubric.min_question_score  
    
  end

  #Action for entering a new feedback
  #Find the questions for particular feedback from Questions table and display those questions
  def new_feedback
    @review_feedback = ReviewFeedback.new
    @assgt_id = params[:id1]
    @author_id = params[:id2]
    @team_id = params[:id4]
    @review_id = params[:id3]
    @assignment = Assignment.find(@assgt_id)
    @questions = Question.find(:all,:conditions => ["questionnaire_id = ?", @assignment.author_feedback_questionnaire_id]) 
    @rubric = Questionnaire.find(@assignment.author_feedback_questionnaire_id)
    @max = @rubric.max_question_score
    @min = @rubric.min_question_score  
      
    
  end
  #Action for creating a new feedback record in the ReviewFeedback table.
  #Save the comments of Feedback in review scores table and the additional cooment in ReviewFeedback table
  def create_feedback
    
    @review_feedback = ReviewFeedback.new
    @assgt_id = params[:assgt_id]
    @author_id = params[:author_id]
    @review_id = params[:review_id]
    @team_id = params[:team_id]
    
    @review_feedback.additional_comment = params[:new_feedback][:comments]
    @review_feedback.assignment_id = @assgt_id
    @review_feedback.author_id = @author_id
    @review_feedback.review_id = @review_id
    @review_feedback.team_id = @team_id
    
    if @review_feedback.save
        # create review scores for a particular author feedback
        latest_author_feedback_id = ReviewFeedback.find_by_sql ("select max(id) as id from review_feedbacks")[0].id 
        if params[:new_review_score]
          for review_key in params[:new_review_score].keys
            rs = Score.new(params[:new_review_score][review_key])
            rs.instance_id = latest_author_feedback_id
            rs.question_id = params[:new_question][review_key]
            rs.score = params[:new_score][review_key]
            # determine whether the rubric is an author feedback rubric
            rs.questionnaire_type_id = QuestionnaireType.find_by_name("Author Feedback").id        
            rs.save        
          end
          flash[:notice] = 'ReviewFeedback was successfully created.'
          redirect_to :action=> 'view_feedback', :id1 =>params[:assgt_id], :id2 =>params[:author_id], :id3=>params[:review_id], :id4=>params[:team_id]
        end
    end
  end
 
  #Action for updating a previous feedback and inserting new values in the ReviewFeedback and Scores table
  def update_feedback
    @a = (params[:review_id])
    @b = (params[:author_id])
    @assignment = Assignment.find_by_id(params[:assgt_id])
    if @assignment.team_assignment
    # Find entry in ReviewFeedback table with passed review id and author id
      @reviewfeedback = ReviewFeedback.find(:first, :conditions =>["review_id =? AND team_id = ?", @a, params[:team_id]])
    else  
      @reviewfeedback = ReviewFeedback.find(:first, :conditions =>["review_id =? AND author_id = ?", @a, @b])
    end
    @reviewfeedback.additional_comment = params[:new_reviewfeedback][:comments]
    @rev_id = @reviewfeedback.id
        
    if params[:new_review_score]
      # The new_question array contains all the new questions
      # that should be saved to the database
      for review_key in params[:new_review_score].keys
        question_id = params[:new_question][review_key]
        rs = Score.find(:first,:conditions => ["instance_id = ? AND question_id = ?", @rev_id, question_id])
        rs.comments = params[:new_review_score][review_key][:comments]
        rs.score = params[:new_score][review_key]    
        rs.update
      end      
    end
    if @reviewfeedback.update
      flash[:notice] = 'Review was successfully updated.'
      if @assignment.team_assignment
        redirect_to :action=> 'view_feedback', :id1 =>params[:assgt_id], :id2 =>params[:author_id], :id3=>params[:review_id], :id4=>params[:team_id]
      else
     redirect_to :action=> 'view_feedback', :id1 =>params[:assgt_id], :id2 =>params[:author_id], :id3=>params[:review_id], :id4=>params[:author_id]
      end   
    end    
  end
  
  # Action for Viewing the Feedback previously entered.
  def view_feedback
    @a = (params[:id3])
    @b = (params[:id2])
    @assignment = Assignment.find_by_id(params[:id1])
    if @assignment.team_assignment
    # Find entry in ReviewFeedback table with passed review id and author id
      @reviewfeedback = ReviewFeedback.find(:first, :conditions =>["review_id =? AND team_id = ?", @a, params[:id4]])
    else  
      @reviewfeedback = ReviewFeedback.find(:first, :conditions =>["review_id =? AND author_id = ?", @a, @b])
    end
    #@reviewfeedback = ReviewFeedback.find_by_review_id(params[:id3]) 
    @review_id = @reviewfeedback.id
    
    # determine whether the rubric is an author feedback rubric
    @review_scores = Score.find(:all,:conditions =>["instance_id =? AND questionnaire_type_id = ?", @review_id, QuestionnaireType.find_by_name("Author Feedback").id])
    @assgt_id = params[:id1]
    @author_id = params[:id2]
    @team_id = params[:id4]
    @assgt = Assignment.find(@assgt_id)
    @questions = Question.find(:all,:conditions => ["questionnaire_id = ?", @assgt.author_feedback_questionnaire_id])
  end 
  
  # Action for Instructor to view a review given by the reviwer to an author. The author Feedback will also be available through this action
  def view_feedback_instructor 
    @reviewfeedback = ReviewFeedback.find(:all, :conditions =>["review_id =? AND author_id = ?", (params[:id3]), (params[:id2])]) 
    @review_id = @reviewfeedback.id
    
    # determine whether the rubric is an author feedback rubric
    @review_scores = Score.find(:all,:conditions =>["review_id =? AND questionnaire_type_id = ?", @review_id, QuestionnaireType.find_by_name("Author Feedback").id])
    @assgt_id = params[:id1]
    @author_id = params[:id2]
    @assgt = Assignment.find(@assgt_id)
    @questions = Question.find(:all,:conditions => ["questionnaire_id = ?", @assgt.author_feedback_questionnaire_id])
  end  
  
end
