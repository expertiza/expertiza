class ReviewOfReviewController < ApplicationController
  # This method returns the 
  def get_student_directory(directory_path, directory_num)
    # This assumed that the directory num has already been set
    return RAILS_ROOT + "/pg_data/" + directory_path + "/" + directory_num
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
  
  def list_reviews
    @reviewer_id = session[:user].id
    @assignment_id = params[:id]
    @questions = Question.find(:all,:conditions => ["questionnaire_id = ?", Assignment.find(@assignment_id).review_questionnaire_id])
    @review_mapping = ReviewMapping.find(:all,:conditions => ["reviewer_id = ? and assignment_id = ?", @reviewer_id, @assignment_id])     
  end
  
  def new_review_of_review
    
    @user = params['user']
    @assignment_id = params['assignment']
    @instructor_review = params['instructor_review']
    @eligible_review_mappings = ReviewMapping.find(:all,:conditions => ["reviewer_id <> ? and author_id <> ? and assignment_id = ?", @user, @user, @assignment_id] )
    # This is the review that is eligible for a review of review based on the criteria defined above
    puts "(((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((("
    puts @eligible_review_mappings
    for eligible_review_map in @eligible_review_mappings
      puts "####################################################"
      puts eligible_review_map
      if(ReviewOfReviewMapping.find(:first, :conditions => ["review_mapping_id = ?",eligible_review_map.id])== nil)
        if (Review.find_by_review_mapping_id(eligible_review_map.id))
          puts "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
          @eligible_review_mapping_id = eligible_review_map.id
          @eligible_review_mapping = eligible_review_map
          @eligible_review = Review.find_by_review_mapping_id(@eligible_review_mapping_id)
          puts @eligible_review_mapping_id
        end
      end
    end
    begin   
      @eligible_review_scores = @eligible_review.review_scores
      @assgt = Assignment.find(@assignment_id)    
      @author = Participant.find(:first,:conditions => ["user_id = ? AND assignment_id = ?", @eligible_review_mapping.author_id, @assgt.id])
      @questions = Question.find(:all,:conditions => ["questionnaire_id = ?", @assgt.review_questionnaire_id]) 
      @questionnaire = Questionnaire.find(@assgt.review_questionnaire_id)
      
      
      puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@"
      puts @assgt.id
      if @assgt.team_assignment 
        @author_first_user_id = TeamsUser.find(:first,:conditions => ["team_id=?", @eligible_review_mapping.team_id]).user_id
        @team_members = TeamsUser.find(:all,:conditions => ["team_id=?", @eligible_review_mapping.team_id])
        @author_name = User.find(@author_first_user_id).name;
        @author = Participant.find(:first,:conditions => ["user_id = ? AND assignment_id = ?", @author_first_user_id, @eligible_review_mapping.assignment_id])
      else
        @author_name = User.find(@eligible_review_mapping.author_id).name
        @author = Participant.find(:first,:conditions => ["user_id = ? AND assignment_id = ?", @eligible_review_mapping.author_id, @eligible_review_mapping.assignment_id])
      end
      @max = @questionnaire.max_question_score
      @min = @questionnaire.min_question_score 
      @current_folder = DisplayOption.new
      @current_folder.name = "/"
      if params[:current_folder]
        @current_folder.name = StudentAssignmentHelper::sanitize_folder(params[:current_folder][:name])
      end
      @files = Array.new
      @files = get_submitted_file_list(@direc, @author, @files)
      
      if params['fname']
        view_submitted_file(@current_folder,@author)
      end
      
      @review_scores = @eligible_review.review_scores
      @assgt = Assignment.find(@assignment_id)
      
      @review_of_review = ReviewOfReview.new
      @questions = Question.find(:all,:conditions => ["questionnaire_id = ?", @assgt.review_of_review_questionnaire_id]) 
      @questionnaire = Questionnaire.find(@assgt.review_of_review_questionnaire_id)
      @max = @questionnaire.max_question_score
      @min = @questionnaire.min_question_score
      
      rescue
      flash[:notice] = "Review of review cannot be created now"
      redirect_to :controller =>'review', :action => 'list_reviews', :id => params['assignment']
    end
  end
  
  #follows a link
  #needs to be moved to a separate helper function
  def view_submitted_file(current_folder,author)
    folder_name = StudentAssignmentHelper::sanitize_folder(current_folder.name)
    file_name = StudentAssignmentHelper::sanitize_filename(params['fname'])
    file_split = file_name.split('.')
    if file_split.length > 1 and (file_split[1] == 'htm' or file_split[1] == 'html')
      send_file(RAILS_ROOT + "/pg_data/" + author.assignment.directory_path + "/" + @author.directory_num.to_s + folder_name + "/" + file_name, :type => Mime::HTML.to_s, :disposition => 'inline') 
    else
      send_file(RAILS_ROOT + "/pg_data/" + author.assignment.directory_path + "/" + @author.directory_num.to_s + folder_name + "/" + file_name) 
    end
  end
  
  def get_student_directory(directory_path, directory_num)
    # This assumed that the directory num has already been set
    return RAILS_ROOT + "/pg_data/" + directory_path + "/" + directory_num
  end
  
  def get_submitted_file_list(direc,author,files)
    if(author.directory_num)
      direc = RAILS_ROOT + "/pg_data/" + author.assignment.directory_path + "/" + author.directory_num.to_s
      temp_files = Dir[direc + "/*"]
      for file in temp_files
        if not File.directory?(Dir.pwd + "/" + file) then
          files << file
        end
      end
    end
    return files
  end
  
  def view_review_of_review
    @ror_map_id = ReviewOfReview.find(params[:id]).review_of_review_mapping_id
    @review_id = ReviewOfReviewMapping.find(@ror_map_id).review_id
    @review = Review.find(@review_id)
    @mapping_id = @review_id
    @review_scores = @review.review_scores
    @mapping = ReviewMapping.find(@review.review_mapping_id)
    @assgt = Assignment.find(@mapping.assignment_id)    
    @author = Participant.find(:first,:conditions => ["user_id = ? AND assignment_id = ?", @mapping.author_id, @assgt.id])
    @questions = Question.find(:all,:conditions => ["questionnaire_id = ?", @assgt.review_questionnaire_id]) 
    @questionnaire = Questionnaire.find(@assgt.review_questionnaire_id)
    
    if @assgt.team_assignment 
      @author_first_user_id = TeamsUser.find(:first,:conditions => ["team_id=?", @mapping.team_id]).user_id
      @team_members = TeamsUser.find(:all,:conditions => ["team_id=?", @mapping.team_id])
      @author_name = User.find(@author_first_user_id).name;
      @author = Participant.find(:first,:conditions => ["user_id = ? AND assignment_id = ?", @author_first_user_id, @mapping.assignment_id])
    else
      @author_name = User.find(@mapping.author_id).name
      @author = Participant.find(:first,:conditions => ["user_id = ? AND assignment_id = ?", @mapping.author_id, @mapping.assignment_id])
    end
    
    @max = @questionnaire.max_question_score
    @min = @questionnaire.min_question_score 
    
    @current_folder = DisplayOption.new
    @current_folder.name = "/"
    if params[:current_folder]
      @current_folder.name = StudentAssignmentHelper::sanitize_folder(params[:current_folder][:name])
    end
    
    @files = Array.new
    @files = get_submitted_file_list(@direc, @author, @files)
    
    if params['fname']
      view_submitted_file(@current_folder,@author)
    end   
    
    
    @review_of_review = ReviewOfReview.find(params[:id])
    @ror_mapping_id = params[:id]
    @ror_review_scores = @review_of_review.review_of_review_scores
    @ror_mapping = ReviewMapping.find(@review_of_review.review_of_review_mapping_id)
    @ror_assgt = Assignment.find(@ror_mapping.assignment_id)    
    @ror_author = Participant.find(:first,:conditions => ["user_id = ? AND assignment_id = ?", @ror_mapping.author_id, @ror_assgt.id])
    @ror_questions = Question.find(:all,:conditions => ["questionnaire_id = ?", @ror_assgt.review_of_review_questionnaire_id]) 
    @ror_questionnaire = Questionnaire.find(@ror_assgt.review_of_review_questionnaire_id)
    @ror_max = @ror_questionnaire.max_question_score
    @ror_min = @ror_questionnaire.min_question_score 
    
  end
  def list_review_of_review
    
  end
  
  def create_review_of_review
    
    @review_of_review_mapping = ReviewOfReviewMapping.new
    @review_of_review_mapping.review_mapping_id = params[:review_mapping_id]
    @review_of_review_mapping.reviewer_id = params[:user]
    @review_of_review_mapping.review_id = params[:review_id]
    @review_of_review_mapping.assignment_id = params[:assgt_id]
    @review_of_review_mapping.save
    
    @ror_mapping = ReviewOfReviewMapping.find(:first, :conditions => ["review_id = ? and reviewer_id = ? ", params[:review_id], params[:user]])
    
    
    
    
    @review_of_review = ReviewOfReview.new
    @review_of_review.review_of_review_mapping_id = @ror_mapping.id
    @due_dates = DueDate.find(:all, :conditions => ["assignment_id = ?",params['assignment']])
    @review_phase = find_review_phase(@due_dates)
    #if(@review_phase != 2)
    
    if params[:new_review_score]
      # The new_question array contains all the new questions
      # that should be saved to the database
      for review_key in params[:new_review_score].keys
        rs = ReviewOfReviewScore.new(params[:new_review_score][review_key])
        rs.question_id = params[:new_question][review_key]
        rs.score = params[:new_score][review_key]
        @review_of_review.review_of_review_scores << rs
      end      
    end
    if @review_of_review.save
      #send message to reviewers(s) when review of review has been updated
      #ajbudlon, sept 07, 2007    
      #@review_of_review.email
      if params['instructor_review']
        flash[:notice] = 'Review of review was successfully saved.'
        redirect_to :controller => 'assignment', :action => 'ror_for_instructors', :id => params[:assgt_id]
      else
        flash[:notice] = 'Review of review was successfully saved.' + params['instructor_review']
        redirect_to :controller => 'review', :action => 'list_reviews', :id => params[:assgt_id]
      end
    else # If something goes wrong, stay at same page
      if params['instructor_review']
        render :controller => 'assignment', :action => 'ror_for_instructors', :id => params[:assgt_id]
      else
        render :action => 'view_review'
      end
    end
  end
end
