class ReviewController < ApplicationController
  helper :wiki
  helper :student_assignment
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
  
  def self.process_review(id,current_folder)   
    @review = Review.find(id)
    @mapping_id = id
    @review_scores = @review.review_scores
    @mapping = ReviewMapping.find(@review.review_mapping_id)
    @assgt = Assignment.find(@mapping.assignment_id)    
    @author = AssignmentParticipant.find(:first,:conditions => ["user_id = ? AND parent_id = ?", @mapping.author_id, @assgt.id])
    @questions = Question.find(:all,:conditions => ["questionnaire_id = ?", @assgt.review_questionnaire_id]) 
    @questionnaire = Questionnaire.find(@assgt.review_questionnaire_id)
    if @assgt.team_assignment 
      @author_first_user_id = TeamsUser.find(:first,:conditions => ["team_id=?", @mapping.team_id]).user_id
      @team_members = TeamsUser.find(:all,:conditions => ["team_id=?", @mapping.team_id])
      @author_name = User.find(@author_first_user_id).name;
      @author = AssignmentParticipant.find(:first,:conditions => ["user_id = ? AND parent_id = ?", @author_first_user_id, @mapping.assignment_id])
    else
      @author_name = User.find(@mapping.author_id).name
      @author = AssignmentParticipant.find(:first,:conditions => ["user_id = ? AND parent_id = ?", @mapping.author_id, @mapping.assignment_id])
    end
    @link = @author.submitted_hyperlink
    @max = @questionnaire.max_question_score
    @min = @questionnaire.min_question_score     
    @files = Array.new
    @files = @author.get_submitted_files()
    
    return @links,@review,@mapping_id,@review_scores,@mapping,@assgt,@author,@questions,@questionnaire,@author_first_user_id,@team_members,@author_name,@max,@min,@current_folder,@files,@direc
  end
  
  def view_review
    @links,@review,@mapping_id,@review_scores,@mapping,@assgt,@author,@questions,@questionnaire,@author_first_user_id,@team_members,@author_name,@max,@min,@current_folder,@files,@direc = ReviewController.process_review(params[:id],params[:current_folder])
    
    @review_id=params[:id]
    
    # determine whether the rubric is a review rubric  
    @review_scores1 = ReviewScore.find(:all,:conditions =>["review_id =? AND questionnaire_type_id = ?", @review_id, QuestionnaireType.find_by_name("Review Rubric").id])
    if( ReviewFeedback.find_by_review_id(@review_id))
      if (ReviewFeedback.find(:first,:conditions =>["review_id = ? and author_id = ?", @review_id,  @a]))
        @reviewfeedback_id_1 = ReviewFeedback.find(:first,:conditions =>["review_id = ? and author_id = ?", @review_id,  @a])
        @review_scores2 = ReviewScore.find(:all,:conditions =>["review_id =? AND questionnaire_type_id = ?", @reviewfeedback_id_1.id, QuestionnaireType.find_by_name("Author Feedback").id])
      end
      if (ReviewFeedback.find(:first,:conditions =>["review_id = ? and author_id != ?", @review_id,  @a]))
        @reviewfeedback_id_2 = ReviewFeedback.find(:first,:conditions =>["review_id = ? and author_id != ?", @review_id,  @a])
        @review_scores3 = ReviewScore.find(:all,:conditions =>["review_id =? AND questionnaire_type_id = ?", @reviewfeedback_id_2.id, QuestionnaireType.find_by_name("Author Feedback").id])
      end     
    end
    
    @current_folder = DisplayOption.new
    @current_folder.name = "/"
    if params[:current_folder]
      @current_folder.name = FileHelper::sanitize_folder(params[:current_folder][:name])
    end
    
    if params['fname']
      view_submitted_file(@author,params['fname'],@current_folder)
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
    @links,@review,@mapping_id,@review_scores,@mapping,@assgt,@author,@questions,@questionnaire,@author_first_user_id,@team_members,@author_name,@max,@min,@current_folder,@files,@direc = ReviewController.process_review(params[:id],params[:current_folder])
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
        rs = ReviewScore.find(:first,:conditions => ["review_id = ? AND question_id = ?", @review.id, question_id])
        rs.comments = params[:new_review_score][review_key][:comments]
        rs.score = params[:new_score][review_key]
        ## feedback added
        # determine whether the rubric is a review rubric
        rs.questionnaire_type_id = QuestionnaireType.find_by_name("Review Rubric").id
        ##
        rs.update
      end      
    end
    if @review.update
      #send message to author(s) when review has been updated
      #ajbudlon, sept 07, 2007
      @review.email
      flash[:notice] = 'Review was successfully saved.'
      redirect_to :action => 'list_reviews', :id => params[:assgt_id]
    else # If something goes wrong, stay at same page
      render :action => 'view_review'
    end
    
  end
  
  def new_review
    
    @review = Review.new
    @mapping_id = params[:id]
    #    @mapping = ReviewMapping.find(params[:id])
    @mapping = 
    begin 
      ReviewMapping.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      nil    
    end    
    # if we did'nt find the mapping, we must be doing dynamic reviewer assignment
    if (@mapping == nil)    
      
      @assignment = Assignment.find(params[:assignment])
      if (@assignment.team_assignment)
        rm = TeamReviewMappingManager.new
      else
        rm = IndividualReviewMappingManager.new
      end
      @mapping = rm.generateReviewMapping(@assignment, session[:user].id)
      if (@mapping == nil)
        flash[:notice] = 'There are no submissions available for review available at this time. Please check back later.'
        redirect_to :action => 'list_reviews', :id => @assignment.id 
        return
      end   
      # record the timeout value in the session so we can verify that we still own this mapping when we submit it
      session[:review_timeout] = @mapping.timeout.to_s()
    end 
    
    @assgt = Assignment.find(@mapping.assignment_id)
    @questions = Question.find(:all,:conditions => ["questionnaire_id = ?", @assgt.review_questionnaire_id]) 
    @questionnaire = Questionnaire.find(@assgt.review_questionnaire_id)
    @max = @questionnaire.max_question_score
    @min = @questionnaire.min_question_score  
    if @assgt.team_assignment 
      team_user = TeamsUser.find(:first,:conditions => ["team_id=?", @mapping.team_id])
      @author_first_user_id = team_user.user_id
      @team_members = TeamsUser.find(:all,:conditions => ["team_id=?", @mapping.team_id])
      @author_name = User.find(@author_first_user_id).name;
      @author = AssignmentParticipant.find(:first,:conditions => ["user_id = ? AND parent_id = ?", @author_first_user_id, @mapping.assignment_id])
    else
      @author_name = User.find(@mapping.author_id).name
      @author = AssignmentParticipant.find(:first,:conditions => ["user_id = ? AND parent_id = ?", @mapping.author_id, @mapping.assignment_id])
    end
    @link = @author.submitted_hyperlink
    
    @current_folder = DisplayOption.new
    @current_folder.name = "/"
    if params[:current_folder]
      @current_folder.name = FileHelper::sanitize_folder(params[:current_folder][:name])
    end
    @files = Array.new
    @files = @author.get_submitted_files()
    
    if params['fname']
      view_submitted_file(@author,params['fname'],@current_folder)
    end
    
    ##anitha - getting previous scores to populate in the text box.
    
    @old_mapping = ReviewMapping.find(:all, :conditions => ["reviewer_id = ? and assignment_id = ? and author_id = ?", (session[:user]).id, @mapping.assignment_id, @mapping.author_id])
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
        @old_scores = ReviewScore.find(:all, :conditions => ["review_id = ? and questionnaire_type_id = ?", @old_review.id, QuestionnaireType.find_by_name("Review Rubric").id])
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
    @review = Review.new
    @review.review_mapping_id = params[:mapping_id]
    @review.additional_comment = params[:new_review][:comments]
    @mapping = ReviewMapping.find(params[:mapping_id])
    @assignment = Assignment.find(@mapping.assignment_id)
    if @assignment.mapping_strategy_id == 2
      # compare the timeout value in the session to the mapping so we can verify that we still own it
      if session[:review_timeout] != @mapping.timeout.to_s() || session[:user].id != @mapping.reviewer_id
        flash[:notice] = 'The time for submitting the review has been exceeded. Please select another review.'
        session[:review_timeout] = nil
        redirect_to :action => 'list_reviews', :id => @assignment.id 
        return
      end
      session[:review_timeout] = nil
    end
    
    if @assignment.team_assignment && params[:team_id] != nil
      @mapping.team_id = params[:team_id]
    end 
    @due_dates = DueDate.find(:all, :conditions => ["assignment_id = ?",@assignment_id])
    @review_phase = find_review_phase(@due_dates)
    if params[:new_review_score]
      # The new_question array contains all the new questions
      # that should be saved to the database
      for review_key in params[:new_review_score].keys
        rs = ReviewScore.new(params[:new_review_score][review_key])
        rs.question_id = params[:new_question][review_key]
        rs.score = params[:new_score][review_key]
        ## feed back added
        # determine whether the rubric is a review rubric
        rs.questionnaire_type_id = QuestionnaireType.find_by_name("Review Rubric").id
        ##
        @review.review_scores << rs
      end      
    end
    if @review.save

      #null out the mapping's timeout value to indicate that its been submitted
      @mapping.timeout = nil
      @mapping.save
      
      #send message to author(s) when review has been updated
      @review.email
      flash[:notice] = 'Review was successfully saved.'
      redirect_to :action => 'list_reviews', :id => params[:assgt_id]
    else # If something goes wrong, stay at same page
      render :action => 'view_review'
    end
  end
  
  def feedback
    @reviewer_id = session[:user].id
    @assignment_id = params[:id]
    @questions = Question.find(:all,:conditions => ["questionnaire_id = ?", Assignment.find(@assignment_id).review_questionnaire_id])
    @review_mapping = ReviewMapping.find(:all,:conditions => ["reviewer_id = ? and assignment_id = ?", @reviewer_id, @assignment_id])   
  end
  
  def list_reviews
    @reviewer_id = session[:user].id
    @assignment_id = params[:id]
    @student = AssignmentParticipant.find(:first, :conditions => ['user_id = ? and parent_id = ?',@reviewer_id,@assignment_id])
    @assignment = Assignment.find(@assignment_id)
    @questions = Question.find(:all,:conditions => ["questionnaire_id = ?", Assignment.find(@assignment_id).review_questionnaire_id])
    # Finding the current phase that we are in
    due_dates = DueDate.find(:all, :conditions => ["assignment_id = ?",@assignment_id])
    @very_last_due_date = DueDate.find(:all,:order => "due_at DESC", :limit =>1, :conditions => ["assignment_id = ?",@assignment_id])
    next_due_date = @very_last_due_date[0]
    for due_date in due_dates
      if due_date.due_at > Time.now
        if due_date.due_at < next_due_date.due_at
          next_due_date = due_date
        end
      end
    end
    @review_phase = next_due_date.deadline_type_id;
    if next_due_date.review_of_review_allowed_id == 2 or next_due_date.review_of_review_allowed_id == 3
      if @review_phase == 5
        @can_view_metareview =1
      end
    end    
    if @assignment.team_assignment
      query = "SELECT distinct review_mappings.* FROM `review_mappings`, `teams_users`"
      query = query + " WHERE review_mappings.assignment_id = "+@assignment_id.to_s
      query = query + " and review_mappings.reviewer_id = "+@reviewer_id.to_s
      query = query + " and review_mappings.team_id = teams_users.team_id"
      @review_mapping = ReviewMapping.find_by_sql(query)
    else
      @review_mapping = ReviewMapping.find(:all,:conditions => ["reviewer_id = ? and assignment_id = ?", @reviewer_id, @assignment_id])
    end
    reviews_left = @assignment.num_reviews - @review_mapping.size()
    if (reviews_left > 0 && @assignment.mapping_strategy_id == 2)
      for i in 1..reviews_left do
        @placeholder = ReviewMapping.new
        @placeholder.id = 999
        @placeholder.assignment_id = @assignment_id
        @review_mapping << @placeholder
      end
    end
    mapping_ids = Array.new
    @review_mapping.each{
      |mapping|
      mapping_ids << mapping.id
    }
    
    query = "select distinct review_of_review_mappings.* from review_of_review_mappings, review_mappings"
    query = query + " where review_mappings.id = review_of_review_mappings.review_mapping_id"
    query = query + " and review_mappings.assignment_id = "+@assignment_id.to_s
    query = query + " and review_of_review_mappings.review_reviewer_id = "+@reviewer_id.to_s
    @review_of_review_mappings = ReviewOfReviewMapping.find_by_sql(query)
    
  end
  
  
  #viewing review and giving feedback by the instructor to the reviewer 
  # This page should show the review by the reviewer and the feedback obtained by the author if any. The instructor has the option to either give a new feedback or edit and view his previous feedback
  def view_review_instructor  
    @review,@mapping_id,@review_scores,@mapping,@assgt,@author,@questions,@rubric,@author_first_user_id,@team_members,@author_name,@max,@min,@current_folder,@files,@direc = ReviewController.process_review(params[:id],params[:current_folder])
    @a = @author.user_id
    
    @user_id = session[:user].id
    @review_id=params[:id]
    # determine whether the rubric is a review rubric
    @review_scores1 = ReviewScore.find(:all,:conditions =>["review_id =? AND questionnaire_type_id = ?", @review_id, QuestionnaireType.find_by_name("Review Rubric").id])
    @reviewfeedback = ReviewFeedback.find_by_review_id(@review_id)
    if (@reviewfeedback)
      @reviewfeedback_id = @reviewfeedback.id
      @author_id = @reviewfeedback.author_id
    end
    # determine whether the rubric is an author feedback rubric
    @review_scores2 = ReviewScore.find(:all,:conditions =>["review_id =? AND questionnaire_type_id = ?", @reviewfeedback_id, QuestionnaireType.find_by_name("Author Feedback").id])
    @current_folder = DisplayOption.new
    @current_folder.name = "/"
    if params[:current_folder]
      @current_folder.name = StudentAssignmentHelper::sanitize_folder(params[:current_folder][:name])
    end
    
    if params['fname']
      view_submitted_file(@author,params['fname'],@current_folder)
    end   
    
  end
  
  #creating review for author by the instructor
  def review_for_author
    @instructor_id = session[:user].id
    @review_id = params[:id]
    @a = params[:id2]    
    @assgt = Assignment.find(:first, :conditions => ["id = ?", @a])
    if @assgt.team_assignment == true # we need to find the team id
      team = TeamsUser.find_by_sql("select * from teams_users where team_id in(select id from teams where assignment_id="+@a.to_s+") and user_id="+params[:user_id].to_s)
      logger.info ""+team[0].id.to_s
      @review_mapping = ReviewMapping.find(:all, :conditions => ["assignment_id = ? and team_id=?", @a, team[0].team_id])
      @author_first_user_id = TeamsUser.find(:first,:conditions => ["team_id=?", team[0].team_id]).user_id
      @team_members = TeamsUser.find(:all,:conditions => ["team_id=?", @review_mapping[0].team_id])
      @author_name = User.find(params[:user_id]).name;
      @author_id = @author_first_user_id
      @author = AssignmentParticipant.find(:first,:conditions => ["user_id = ? AND parent_id = ?", @author_first_user_id, @review_mapping[0].assignment_id])
    else
      @review_mapping = ReviewMapping.find(:all, :conditions => ["author_id= ? and assignment_id = ?", params[:user_id], @a])
      @author_id = @review_mapping[0].author_id
      @author = User.find(:first, :conditions => ["id =?",@author_id])
    end
    @participant = AssignmentParticipant.find(:first,:conditions => ["user_id = ? AND parent_id = ?", @author_id, @review_mapping[0].assignment_id])
    @link = @participant.submitted_hyperlink
    @participant = AssignmentParticipant.find(:first,:conditions => ["user_id = ? AND parent_id = ?", @author_id, @review_mapping[0].assignment_id])
    @link = @participant.submitted_hyperlink
    @files = Array.new
    @files = @participant.get_submitted_files()
    @current_folder = DisplayOption.new
    @current_folder.name = "/"
    if params[:current_folder]
      @current_folder.name = StudentAssignmentHelper::sanitize_folder(params[:current_folder][:name])
    end
    
    if params['fname']
      view_submitted_file(@author,params['fname'],@current_folder)
    end 
    
    @questions = Question.find(:all,:conditions => ["questionnaire_id = ?", @assgt.review_questionnaire_id]) 
    @rubric = Questionnaire.find(@assgt.review_questionnaire_id)
    @max = @rubric.max_question_score
    @min = @rubric.min_question_score    
    
    due_dates = DueDate.find(:all, :conditions => ["assignment_id = ?",@a])
    @very_last_due_date = DueDate.find(:all,:order => "due_at DESC", :limit =>1, :conditions => ["assignment_id = ?",@a])
    next_due_date = @very_last_due_date[0]
    for due_date in due_dates
      if due_date.due_at > Time.now
        if due_date.due_at < next_due_date.due_at
          next_due_date = due_date
        end
      end
    end
    @review_phase = next_due_date.deadline_type_id;
    
    @cur_round = 1
    if !next_due_date.round.nil?
      @cur_round = next_due_date.round
    end
    
    @instructor_author_mapping = ReviewMapping.find(:all, :conditions => ["author_id = ? and reviewer_id = ? and assignment_id = ?", @author_id, @instructor_id, @assgt.id])
    
    if @instructor_author_mapping.length == 0
      @mapping = ReviewMapping.new
      @mapping.author_id = @author_id
      @mapping.reviewer_id = @instructor_id
      @mapping.assignment_id = @a
      @mapping.round = @cur_round
      @mapping.team_id = params[:team_id] if @assgt.team_assignment?
      @mapping.save
      @instructor_author_mapping[0] = @mapping
    end
    
  end
  
  #save review for author
  def save_review_for_author
    
    #check if the instrcutor has given a review. if presen, update it
    @review = Review.new
    #@review.review_mapping_id = params[:mapping_id]
    @review.additional_comment = params[:new_review][:comments]
    #@mapping = ReviewMapping.find(params[:mapping_id])
    @assignment = Assignment.find(params[:assgt_id])
    @due_dates = DueDate.find(:all, :conditions => ["assignment_id = ?",@assignment.id])
    @review_phase = find_review_phase(@due_dates)
    
    #if(@review_phase != 2)
    
    
    if params[:new_review_score]
      # The new_question array contains all the new questions
      # that should be saved to the database
      for review_key in params[:new_review_score].keys
        rs = ReviewScore.new(params[:new_review_score][review_key])
        rs.question_id = params[:new_question][review_key]
        rs.score = params[:new_score][review_key]
        @review.review_scores << rs
      end      
    end
    if @review.save
      #send message to author(s) when review has been updated
      #@review.email
      flash[:notice] = 'Review was successfully saved.'
      redirect_to :action => 'view_report', :id => params[:assgt_id]
    else # If something goes wrong, stay at same page
      render :action => 'view_review'
    end
  end    
  
  def view_submitted_file(author, fname, current_folder)
    folder_name = FileHelper::sanitize_folder(current_folder.name)
    file_name = FileHelper::sanitize_filename(fname)
    file_split = file_name.split('.')
    if file_split.length > 1 and (file_split[1] == 'htm' or file_split[1] == 'html')
      send_file(author.get_path + folder_name + file_name, :type => Mime::HTML.to_s, :disposition => 'inline') 
    else
      send_file(author.get_path + folder_name + file_name) 
    end
  end  
end #class ends
