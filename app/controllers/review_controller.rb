class ReviewController < ApplicationController  
  helper :wiki
  helper :submitted_content
  helper :file
  
  def list
    # lists the reviews that the current user is assigned to do
    user_id = session[:user].id
    assignment_id = params[:assignment_id]
    @review_mappings = ReviewMappings.find_by_sql("select * from review_mappings, reviews where reviewer_id = " +
    user_id + "and assignment_id =" + assignment_id + "and reviews.review_mapping_id = review_mappings.id")
    @review_pages, @reviews = paginate :users, :order => 'review_num_for_reviewer', :conditions => ["parent_id = ? AND role_id = ?", user_id, Role::ADMINISTRATOR], :per_page => 50
  end
  
  def display
    # Display the review(s) of the student whom this author has selected to review now.
    # The reviews of old versions should open in a different window, so that the reviewer can scroll through
    # them, and through the author's reponses (if any).
    # If a review has already been submitted for the current version, then the prose comments should
    # populate the text boxes that the reviewer is about to revise.
    # In any case, if this reviewer has reviewed this author on (any version of) this assignment, the 
    # previously assigned scores should populate the dropboxes used to assign scores.
    # If a questionnaire question has been added since the last time this reviewer reviewed this author, a
    # default score (probably the lowest possible score) should appear in the dropbox.
  end
  
  def self.show_review(id)   
    @review = Review.find(id)
    @mapping = @review.mapping
    @assgt = @mapping.assignment

    @questionnaire = Questionnaire.find(@assgt.review_questionnaire_id)    
    @questions = @questionnaire.questions
    
    @review_scores = Array.new
    @questions.each{
      | question |
      @review_scores << Score.find_by_instance_id_and_question_id(@review.id,question.id)
    }
    
    @author = @mapping.reviewee

    if @assgt.team_assignment 
      @team_members = @mapping.reviewee.get_participants 
      #use @author.handle to spider by participant handle
      #@author_name = User.find(@author_first_user_id).name;
      @author = @team_members.first 
      @author_name = @author.handle
    else
      #user @author.handle to spider by participant handle
      #@author_name = User.find(@mapping.author_id).name
      @author_name = @author.handle
    end
    @link = @author.submitted_hyperlink
    @max = @questionnaire.max_question_score
    @min = @questionnaire.min_question_score     
    @files = Array.new
    @files = @author.get_submitted_files()
    
    return @links,@review,@mapping_id,@review_scores,@mapping,@assgt,@author,@questions,@questionnaire,@author_first_user_id,@team_members,@author_name,@max,@min,@files,@direc
  end
  
  def view_review
    @links,@review,@mapping_id,@review_scores,@mapping,@assignment,@participant,@questions,@questionnaire,@author_first_user_id,@team_members,@author_name,@max,@min,@files,@direc = ReviewController.show_review(params[:id])
    
    @review_id=params[:id]
       
    current_folder = DisplayOption.new
    current_folder.name = "/"
    @files = Array.new
    begin
      @files = @participant.get_files(@participant.get_path + current_folder.name)
    rescue
    end
   
  end
  
  def view_file
    @current_folder = DisplayOption.new
    @current_folder.name = "/"
    if params[:current_folder]
      @current_folder.name = FileHelper::sanitize_folder(params[:current_folder][:name])
    end
    @mapping = ReviewMapping.find(params[:id])
    @assgt = Assignment.find(@mapping.assignment_id)    
    if @assgt.team_assignment
      @author_first_user_id = TeamsUser.find(:first,:conditions => ["team_id=?", @mapping.team_id]).user_id
      @author = AssignmentParticipant.find(:first,:conditions => ["user_id = ? AND parent_id = ?", @author_first_user_id, @mapping.assignment_id])
    else
      @author = AssignmentParticipant.find(:first,:conditions => ["user_id = ? AND parent_id = ?", @mapping.author_id, @mapping.assignment_id])
    end
    view_submitted_file(@author,params['fname'],@current_folder)
  end
  
  def edit_review
    @links,@review,@mapping_id,@review_scores,@mapping,@assignment,@participant,@questions,@questionnaire,@author_first_user_id,@team_members,@author_name,@max,@min,@files,@direc = ReviewController.show_review(params[:id])
    @current_folder = DisplayOption.new
    @current_folder.name = "/"
    if params[:current_folder]
      @current_folder.name = FileHelper::sanitize_folder(params[:current_folder][:name])
    end
    
    #send message to author(s) when review has been updated
    #@review.email    
    if params['fname']
      view_submitted_file(@author,params['fname'],@current_folder)
    end
  end
  
  
  
  def update_review
    @review = Review.find(params[:review_id])
    @review.additional_comment = params[:new_review][:comments]
    if params[:new_review_score]
      # The new_question array contains all the new questions
      # that should be saved to the database
      for review_key in params[:new_review_score].keys
        question_id = params[:new_question][review_key]
        rs = Score.find_by_instance_id_and_question_id(@review.id, question_id)
        rs.comments = params[:new_review_score][review_key][:comments]
        rs.score = params[:new_score][review_key]
        ## feedback added                
        rs.update
      end      
    end
    if @review.update
      #send message to author(s) when review has been updated
      #ajbudlon, sept 07, 2007
      @review.email
      
      #determine if the new review meets the criteria set by the instructor's 
      #notification limits  
      compare_scores      
      
      flash[:note] = 'Review was successfully saved.'
      redirect_to :controller => 'student_review', :action => 'list', :id => @review.mapping.reviewer.id
    else # If something goes wrong, stay at same page
      render :action => 'view_review'
    end
    
  end
  
  def new_review    
    @review = Review.new
    @mapping_id = params[:id]
    @mapping = ReviewMapping.find(params[:id])
    
    @assignment = @mapping.assignment
    @questionnaire = Questionnaire.find(@assignment.review_questionnaire_id)
    @questions = @questionnaire.questions
    @max = @questionnaire.max_question_score
    @min = @questionnaire.min_question_score  
    if @assignment.team_assignment 
      @team_members = @mapping.reviewee.get_participants
      @participant = @team_members.first
      @author_first_user_id = @participant.user_id
      @author_name = @participant.user.name      
    else
      @author_name = @mapping.reviewee.user.name
      @participant = @mapping.reviewee
    end
    @link = @participant.submitted_hyperlink
    
    @current_folder = DisplayOption.new
    @current_folder.name = "/"
    if params[:current_folder]
      @current_folder.name = FileHelper::sanitize_folder(params[:current_folder][:name])
    end
    @files = Array.new
    @files = @participant.get_submitted_files()
    
    if params['fname']
      view_submitted_file(@author,params['fname'],@current_folder)
    end
    
    ##anitha - getting previous scores to populate in the text box.
    reviewer = AssignmentParticipant.find_by_user_id_and_parent_id(session[:user].id, @mapping.assignment.id)
    @old_mapping = ReviewMapping.find(:all, :conditions => ["reviewer_id = ? and reviewed_object_id = ? and reviewee_id = ?", reviewer.id, @mapping.assignment.id, @mapping.reviewee.id])
    @old_review_mapping = @old_mapping[0]
    i = 1
    for mapping in @old_mapping
      if @mapping.id == mapping.id        
        return
      end
      @old_review = Review.find_by_review_mapping_id(mapping.id)
      if (@old_review)
        @old_review_mapping = mapping
        # determine whether the rubric is a review rubric
        @old_scores = Score.find(:all, :conditions => ["instance_id = ? and questionnaire_type_id = ?", @old_review.id, QuestionnaireType.find_by_name("Review").id])
      end
      i+=1
    end
  end  
  
  def find_review_phase(due_dates)
    # Find the next due date (after the current date/time), and then find the type of deadline it is.
    @very_last_due_date = DueDate.find(:all,:order => "due_at DESC", :limit =>1)
    next_due_date = @very_last_due_date[0]
    for due_date in due_dates
      if due_date.due_at > Time.now
        if due_date.due_at < next_due_date.due_at
          next_due_date = due_date
        end
      end
    end
    @review_phase = next_due_date.deadline_type_id;
    return @review_phase
  end
  
  def create_review
    mapping = ReviewMapping.find(params[:mapping_id])    
    @review = Review.create(:mapping_id => mapping.id, :additional_comment => params[:new_review][:comments])
    
    @due_dates = DueDate.find(:all, :conditions => ["assignment_id = ?",mapping.assignment.id])
    @review_phase = find_review_phase(@due_dates)
    if @review.save
      if params[:new_review_score]
        latest_review_id = Review.find_by_sql("select max(id) as id from reviews")[0].id
        # The new_question array contains all the new questions
        # that should be saved to the database
        for review_key in params[:new_review_score].keys
          rs = Score.new(params[:new_review_score][review_key])
          rs.instance_id = latest_review_id
          rs.question_id = params[:new_question][review_key]
          rs.score = params[:new_score][review_key]
          ## feed back added
          rs.save
        end      
      end       
      
      #determine if the new review meets the criteria set by the instructor's 
      #notification limits      
      compare_scores
      
      #send message to author(s) when review has been updated
      @review.email            
      flash[:note] = 'Review was successfully saved.'
      redirect_to :controller => 'student_review', :action => 'list', :id => mapping.reviewer.id
    else # If something goes wrong, stay at same page
      render :action => 'view_review'
    end
  end
  
  # Compute the currently awarded scores for the reviewee
  # If the new review's score is greater than or less than 
  # the existing scores by a given percentage (defined by
  # the instructor) then notify the instructor.
  # ajbudlon, nov 18, 2008
  def compare_scores              
    total, count = ReviewHelper.get_total_scores(@review.mapping.reviewee.get_reviews,@review)     
    if count > 0
      questionnaire = Questionnaire.find(@review.mapping.assignment.review_questionnaire_id)
      ReviewHelper.notify_instructor(@review.mapping.assignment,@review,questionnaire,total,count)
    end
  end
  
  def feedback
    @reviewer_id = session[:user].id
    @assignment_id = params[:id]
    @questions = Question.find(:all,:conditions => ["questionnaire_id = ?", Assignment.find(@assignment_id).review_questionnaire_id])
    @review_mapping = ReviewMapping.find(:all,:conditions => ["reviewer_id = ? and assignment_id = ?", @reviewer_id, @assignment_id])   
  end
   
end #class ends
