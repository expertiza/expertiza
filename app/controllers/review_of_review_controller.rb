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
    @ror_mapping = ReviewOfReviewMapping.find(params[:id])
    @user = session[:user].id
    @eligible_review_mapping = ReviewMapping.find(@ror_mapping.review_mapping_id)
    @eligible_review = Review.find_by_review_mapping_id(@eligible_review_mapping.id)
    
    begin
        @links, @review, @mapping_id, @review_scores, @mapping, @assgt, @author, @questions, @questionnaire, @author_first_user_id, @team_members, @author_name, @max, @min, @current_folder, @files, @direct = ReviewController.process_review(@eligible_review.id, params[:current_folder])
        @current_folder = DisplayOption.new
        @current_folder = "/"
        if params[:current_folder]
          @current_folder.name = FileHelper.sanitize_folder(params[:current_folder][:name])          
        end
        if params['fname']
          view_submitted_file(@current_folder,@author)
        end
        
        @ror_questions = Question.find(:all, :conditions => ['questionnaire_id = ?', @assgt.review_of_review_questionnaire_id])
        @ror_questionnaire = Questionnaire.find(@assgt.review_of_review_questionnaire_id)
        @ror_max = @ror_questionnaire.max_question_score
        @ror_min = @ror_questionnaire.min_question_score        
      rescue
        flash[:notice] = "Review of review cannot be created now. Cause: "+$!
        redirect_to :controller => 'review', :action => 'list_reviews', :id => review_mapping.assignment_id
      end    
  end
  
  def initialize_ror
    @review_of_review = ReviewOfReview.find(params[:id])    
    @ror_mapping = ReviewOfReviewMapping.find(@review_of_review.review_of_review_mapping_id)
    r_mapping = ReviewMapping.find(@ror_mapping.review_mapping_id)
    
    @eligible_review = Review.find_by_review_mapping_id(r_mapping.id)
    
    @links,@review,@mapping_id,@review_scores,@mapping,@assgt,@author,@questions,@questionnaire,@author_first_user_id,@team_members,@author_name,@max,@min,@current_folder,@files,@direc = ReviewController.process_review(@eligible_review.id,params[:current_folder])
    if @assgt.team_assignment 
      @author_first_user_id = TeamsUser.find(:first,:conditions => ["team_id=?", @mapping.team_id]).user_id
      @team_members = TeamsUser.find(:all,:conditions => ["team_id=?", @mapping.team_id])
      @author_name = User.find(@author_first_user_id).name;
      @author = AssignmentParticipant.find(:first,:conditions => ["user_id = ? AND parent_id = ?", @author_first_user_id, @mapping.assignment_id])
    else
      @author_name = User.find(@mapping.author_id).name
      @author = AssignmentParticipant.find(:first,:conditions => ["user_id = ? AND parent_id = ?", @mapping.author_id, @mapping.assignment_id])
    end
    
    @max = @questionnaire.max_question_score
    @min = @questionnaire.min_question_score 
    @current_folder = DisplayOption.new
    @current_folder.name = "/"
    if params[:current_folder]
      @current_folder.name = FileHelper::sanitize_folder(params[:current_folder][:name])
    end
    if params['fname']
      view_submitted_file(@current_folder,@author)
    end   
    @ror_review_scores = ReviewOfReviewScore.find(:all,:conditions => ["review_of_review_id = ?", params[:id]])
    @ror_assgt = Assignment.find(r_mapping.assignment_id)    
    @ror_questions = Question.find(:all,:conditions => ["questionnaire_id = ?", @ror_assgt.review_of_review_questionnaire_id]) 
    @ror_questionnaire = Questionnaire.find(@ror_assgt.review_of_review_questionnaire_id)
    @ror_max = @ror_questionnaire.max_question_score
    @ror_min = @ror_questionnaire.min_question_score
  end
  
  #follows a link
  #needs to be moved to a separate helper function
  def view_submitted_file(current_folder,author)
    folder_name = FileHelper::sanitize_folder(current_folder.name)
    file_name = FileHelper::sanitize_filename(params['fname'])
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
     initialize_ror
  end
  
  def edit_review_of_review
    initialize_ror
  end
  
  def update_review_of_review
    @review_of_review = ReviewOfReview.find(params[:review_of_review_id])
    if params[:new_review_of_review_score]
      # The new_question array contains all the new questions
      # that should be saved to the database
      for review_of_review_key in params[:new_review_of_review_score].keys
        question_id = params[:new_question][review_of_review_key]
        rs = ReviewOfReviewScore.find(:first,:conditions => ["review_of_review_id = ? AND question_id = ?", @review_of_review.id, question_id])
        rs.comments = params[:new_review_of_review_score][review_of_review_key][:comments]
        rs.score = params[:new_score][review_of_review_key]
        rs.update
      end      
    end
    if @review_of_review.update
      flash[:notice] = 'Review of review was successfully saved.'
      redirect_to :controller=>'review', :action => 'list_reviews', :id => params[:assgt_id]
    else # If something goes wrong, stay at same page
      render :action => 'edit_review_of_review', :id=> params[:review_of_review_id]
    end
  end
  
  def create_review_of_review
    review = Review.find(params[:review_id])
    review_mapping = ReviewMapping.find(review.review_mapping_id)
    @ror_mapping = ReviewOfReviewMapping.find(:first, :conditions => ["review_mapping_id = ? and review_reviewer_id = ? ", review_mapping.id, params[:user]])
    @review_of_review = ReviewOfReview.create(:reviewed_at => Time.now, :review_of_review_mapping_id => @ror_mapping.id)    
    if params[:new_review_of_review_score]
      # The new_question array contains all the new questions
      # that should be saved to the database
      for review_of_review_key in params[:new_review_of_review_score].keys
        rs = ReviewOfReviewScore.new(params[:new_review_of_review_score][review_of_review_key])
        rs.question_id = params[:new_question][review_of_review_key]
        rs.score = params[:new_score][review_of_review_key]
        @review_of_review.review_of_review_scores << rs
      end
    end
    begin 
      @review_of_review.save!
      flash[:notice] = 'Review of review was successfully saved.' + params['instructor_review']
      redirect_to :controller => 'review', :action => 'list_reviews', :id => params[:assgt_id]
    rescue
      render :action => 'view_review'
    end
  end
end
