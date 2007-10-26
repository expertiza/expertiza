class ReviewController < ApplicationController
  helper :wiki
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
    # If a rubric question has been added since the last time this reviewer reviewed this author, a
    # default score (probably the lowest possible score) should appear in the dropbox.
  end
  
  
  
  def process_review(id,current_folder)
    @review = Review.find(id)
    @mapping_id = id
    @review_scores = @review.review_scores
    @mapping = ReviewMapping.find(@review.review_mapping_id)
    @assgt = Assignment.find(@mapping.assignment_id)    
    @author = Participant.find(:first,:conditions => ["user_id = ? AND assignment_id = ?", @mapping.author_id, @assgt.id])
    @questions = Question.find(:all,:conditions => ["rubric_id = ?", @assgt.review_rubric_id]) 
    @rubric = Rubric.find(@assgt.review_rubric_id)
    
    if @assgt.team_assignment 
      @author_first_user_id = TeamsUser.find(:first,:conditions => ["team_id=?", @mapping.team_id]).user_id
      @team_members = TeamsUser.find(:all,:conditions => ["team_id=?", @mapping.team_id])
      @author_name = User.find(@author_first_user_id).name;
      @author = Participant.find(:first,:conditions => ["user_id = ? AND assignment_id = ?", @author_first_user_id, @mapping.assignment_id])
    else
      @author_name = User.find(@mapping.author_id).name
      @author = Participant.find(:first,:conditions => ["user_id = ? AND assignment_id = ?", @mapping.author_id, @mapping.assignment_id])
    end
    
    @max = @rubric.max_question_score
    @min = @rubric.min_question_score 
    
    @files = Array.new
    @files = get_submitted_file_list(@direc, @author, @files)
    
    return @review,@mapping_id,@review_scores,@mapping,@assgt,@author,@questions,@rubric,@author_first_user_id,@team_members,@author_name,@max,@min,@current_folder,@files,@direc
  end
  
  def view_review
    @review,@mapping_id,@review_scores,@mapping,@assgt,@author,@questions,@rubric,@author_first_user_id,@team_members,@author_name,@max,@min,@current_folder,@files,@direc = process_review(params[:id],params[:current_folder])
    
    @current_folder = DisplayOption.new
    @current_folder.name = "/"
    if params[:current_folder]
      @current_folder.name = StudentAssignmentHelper::sanitize_folder(params[:current_folder][:name])
    end
    
    if params['fname']
      view_submitted_file(@current_folder,@author)
    end   
  end
  
  def edit_review
    @review,@mapping_id,@review_scores,@mapping,@assgt,@author,@questions,@rubric,@author_first_user_id,@team_members,@author_name,@max,@min,@current_folder,@files,@direc = process_review(params[:id],params[:current_folder])
    @current_folder = DisplayOption.new
    @current_folder.name = "/"
    if params[:current_folder]
      @current_folder.name = StudentAssignmentHelper::sanitize_folder(params[:current_folder][:name])
    end
    
    #send message to author(s) when review has been updated
    #@review.email    
    if params['fname']
      view_submitted_file(@current_folder,@author)
    end
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
    @mapping = ReviewMapping.find(params[:id])
    @assgt = Assignment.find(@mapping.assignment_id)
    @questions = Question.find(:all,:conditions => ["rubric_id = ?", @assgt.review_rubric_id]) 
    @rubric = Rubric.find(@assgt.review_rubric_id)
    @max = @rubric.max_question_score
    @min = @rubric.min_question_score  
    
    if @assgt.team_assignment 
      @author_first_user_id = TeamsUser.find(:first,:conditions => ["team_id=?", @mapping.team_id]).user_id
      @team_members = TeamsUser.find(:all,:conditions => ["team_id=?", @mapping.team_id])
      @author_name = User.find(@author_first_user_id).name;
      @author = Participant.find(:first,:conditions => ["user_id = ? AND assignment_id = ?", @author_first_user_id, @mapping.assignment_id])
    else
      @author_name = User.find(@mapping.author_id).name
      @author = Participant.find(:first,:conditions => ["user_id = ? AND assignment_id = ?", @mapping.author_id, @mapping.assignment_id])
    end
    
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
    params.each do |elem|
      puts "#{elem[0]}, #{elem[1]}" 
    end
    @review = Review.new
    @review.review_mapping_id = params[:mapping_id]
    @review.additional_comment = params[:new_review][:comments]
    @mapping = ReviewMapping.find(params[:mapping_id])
    @assignment = Assignment.find(@mapping.assignment_id)
    @due_dates = DueDate.find(:all, :conditions => ["assignment_id = ?",@assignment_id])
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
    @questions = Question.find(:all,:conditions => ["rubric_id = ?", Assignment.find(@assignment_id).review_rubric_id])
    @review_mapping = ReviewMapping.find(:all,:conditions => ["reviewer_id = ? and assignment_id = ?", @reviewer_id, @assignment_id])   
  end
  
  def list_reviews
    @reviewer_id = session[:user].id
    @assignment_id = params[:id]
    @questions = Question.find(:all,:conditions => ["rubric_id = ?", Assignment.find(@assignment_id).review_rubric_id])
    @review_mapping = ReviewMapping.find(:all,:conditions => ["reviewer_id = ? and assignment_id = ?", @reviewer_id, @assignment_id])   
    @review_of_review_mappings = ReviewOfReviewMapping.find(:all,:conditions => ["reviewer_id = ? and assignment_id = ?", @reviewer_id, @assignment_id])   
    # Finding the current phase that we are in
    due_dates = DueDate.find(:all, :conditions => ["assignment_id = ?",@assignment_id])
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
    if next_due_date.review_of_review_allowed_id == 2 or next_due_date.review_of_review_allowed_id == 3
      if @review_phase == 5
        @can_view_review_of_review =1
      end
    end
  end
  
end
