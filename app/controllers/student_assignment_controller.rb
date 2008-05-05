require 'zip/zip'

class StudentAssignmentController < ApplicationController
  helper :wiki
  helper :student_assignment
  def list
    user_id = session[:user].id
    @user =session[:user]
    @participants = Participant.find(:all, 
                                    :conditions => ['user_id = ?', user_id],
                                    :order => "assignment_id DESC")
  end
  
  def view_publishing
    user_id = session[:user].id
    @user =session[:user]
    @participants = Participant.find(:all, 
                                    :conditions => ['user_id = ?', user_id],
                                    :order => "assignment_id DESC")
  end
  
  def view_actions
    @student = Participant.find(params[:id])
    @assignment_id = @student.assignment_id
    # assignment_id below is the ID of the assignment retrieved from the participants table (the assignment in which this student is participating)
    @due_dates = DueDate.find(:all, :conditions => ["assignment_id = ?",@assignment_id])
    @can_view_your_work, @can_view_others_work = find_viewing_permissions(@due_dates)
    @assigned_surveys = SurveyHelper::get_all_available_surveys(@assignment_id, session[:user].role_id)
  end
  
  def eula_yes
  
    @user = session[:user]
    @user.is_new_user = 0
    
    if @user.save
      flash[:notice] = 'You have accepted the license agreement'
      redirect_to :action => 'list'
    else # If something goes wrong, stay at same page
      render :action => 'list'
    end
  end
  
    def eula_no
      flash[:notice] = 'You have to accept the license agreement in order to use the system'
      redirect_to :action => 'list'
  end
  
#  def set_publish_permission_yes
#    @participant = Participant.find(:first, :conditions => ["id = ?",params[:id]])
#    @participant.permission_granted = 1;
#    @participant_id = params[:id]
#    if @participant.save
#      flash[:notice] = 'Your work will now be published'
#      redirect_to :action => 'submit', :id => @participant_id
#    else # If something goes wrong, stay at same page
#      render :action => 'submit', :id => @participant_id
#    end
#  end
  
  def set_publish_permission_yes
    @participant = Participant.find(:first, :conditions => ["id = ?",params[:participant]])
    @participant.permission_granted = 1;
    @participant_id = params[:id]
    if @participant.save
      flash[:notice] = 'Your work will now be published'
      redirect_to :action => 'view_publishing'
    else # If something goes wrong, stay at same page
      render :action => 'view_publishing'
    end
  end
  
  def set_publish_permission_no
    @participant = Participant.find(:first, :conditions => ["id = ?",params[:participant]])
    @participant.permission_granted = 0;
    @participant_id = params[:id]
    if @participant.save
      flash[:notice] = 'Your work will now be published'
      redirect_to :action => 'view_publishing'
    else # If something goes wrong, stay at same page
      render :action => 'view_publishing'
    end
  end
  
  def set_all_publish_permission_yes
    @participants = Participant.find(:all, :conditions => ["user_id = ?",params[:user]])
    for participant in @participants
      participant.permission_granted = 1;
      if !participant.save
        render :action => 'view_publishing'
      end
    end
    redirect_to :action => 'view_publishing'
  end
  
  def set_all_publish_permission_no
    @participants = Participant.find(:all, :conditions => ["user_id = ?",params[:user]])
    for participant in @participants
      participant.permission_granted = 0;
      if !participant.save
        render :action => 'view_publishing'
      end
    end
    redirect_to :action => 'view_publishing'
  end
  
  def set_future_publish_permission_yes
    @user = session[:user]
    @user.master_permission_granted = 1;
    if @user.save
      redirect_to :action => 'view_publishing'
    else # If something goes wrong, stay at same page
      render :action => 'view_publishing'
    end
  end
  
  def set_future_publish_permission_no
    @user = session[:user]
    @user.master_permission_granted = 0;
    if @user.save
      redirect_to :action => 'view_publishing'
    else # If something goes wrong, stay at same page
      render :action => 'view_publishing'
    end
  end
  
  def view_scores
    @author_id = session[:user].id
    @assignment_id = Participant.find(params[:id]).assignment_id
    @assignment = Assignment.find(@assignment_id)
    if @assignment.team_assignment 
      @team_id = TeamsUser.find(:first,:conditions => ["user_id=? and team_id in (select id from teams where assignment_id=?)", @author_id, @assignment_id]).team_id
      @author_first_user_id = TeamsUser.find(:first,:conditions => ["team_id=?", @team_id]).user_id
      @student = Participant.find(:first,:conditions => ["user_id = ? AND assignment_id = ?", @author_first_user_id, @assignment_id])
      @user_name= session[:user].name
      #@user_name = User.find(@author_first_user_id).name
      @review_mapping = ReviewMapping.find(:all,:conditions => ["team_id = ? and assignment_id = ?", @team_id, @assignment_id])
    elsif !@assignment.team_assignment
      @student = Participant.find(params[:id])
      @user_name= session[:user].name
      @user_name = User.find(@student.user_id).name
      @review_mapping = ReviewMapping.find(:all,:conditions => ["author_id = ? and assignment_id = ?", @author_id, @assignment_id])
    end
    @late_policy = LatePolicy.find(Assignment.find(@assignment_id).due_dates[0].late_policy_id)
    @penalty_units = @student.penalty_accumulated/@late_policy.penalty_period_in_minutes
    
    #the code below finds the sum of the maximum scores of all questions in the questionnaire
    @sum_of_max = 0
    for question in Questionnaire.find(Assignment.find(@assignment_id).review_questionnaire_id).questions
      @sum_of_max += Questionnaire.find(Assignment.find(@assignment_id).review_questionnaire_id).max_question_score
    end
    
    if @student.penalty_accumulated/@late_policy.penalty_period_in_minutes*@late_policy.penalty_per_unit < @late_policy.max_penalty
      @final_penalty = @penalty_units*@late_policy.penalty_per_unit
    elsif @penalty_units ==0
      @final_penalty = 0
    else
      @final_penalty = @late_policy.max_penalty
    end
        
    @review_of_review_mappings = Array.new
    
    @review_mappings_for_author = ReviewMapping.find(:all, :conditions => ["author_id = ?",(session[:user].id)])
    for review_mapping_for_author in @review_mappings_for_author
      if(ReviewOfReviewMapping.find(:first, :conditions => ["review_mapping_id = ?",review_mapping_for_author.id])!= nil)
        puts ReviewOfReviewMapping.find(:first, :conditions => ["review_mapping_id = ?",review_mapping_for_author.id])
        @review_of_review_mappings << ReviewOfReviewMapping.find(:first, :conditions => ["review_mapping_id = ?",review_mapping_for_author.id])
      end
    end
    
  end
  
  def set_feedback
    @participant_id = params[:participant_id]
    @review_id = params[:review_id]
    @assignment_id = params[:assignment_id]
    update_author_feedback(@review_id,@assignment_id,params['author']['text'])
    redirect_to :action => 'view_scores', :id => @participant_id
  end
  
  def update_author_feedback(review_id,assignment_id,text)
    if(ReviewFeedback.find(:first,:conditions =>["review_id = ? and assignment_id = ?", review_id, assignment_id]))
      @review_feedback = ReviewFeedback.find(:first,:conditions =>["review_id = ? and assignment_id = ?", review_id, assignment_id])
      @review_feedback.additional_comments = text
      @review_feedback.update
    else
      @review_feedback = ReviewFeedback.new
      @review_feedback.review_id = review_id
      @review_feedback.assignment_id = assignment_id
      @review_feedback.additional_comments = text
      if @review_feedback.save
        flash[:notice] = 'feedback has been updated'
      end
    end
  end
  
  def view_feedback
    @author_id = session[:user].id
    @assignment_id = Participant.find(params[:id]).assignment_id
    @assignment = Assignment.find(@assignment_id)
     if @assignment.team_assignment 
      @team_id = TeamsUser.find(:first,:conditions => ["user_id=? and team_id in (select id from teams where assignment_id=?)", @author_id, @assignment_id]).team_id
      @team_members = TeamsUser.find(:all,:conditions => ["user_id=? and team_id in (select id from teams where assignment_id=?)", @author_id, @assignment_id]).team_id
      @author_first_user_id = TeamsUser.find(:first,:conditions => ["team_id=?", @team_id]).user_id
      @student = Participant.find(:first,:conditions => ["user_id = ? AND assignment_id = ?", @author_first_user_id, @assignment_id])
      @user_name= session[:user].name
      @review_mapping = ReviewMapping.find(:all,:conditions => ["team_id = ? and assignment_id = ?", @team_id, @assignment_id])
    elsif !@assignment.team_assignment
      @student = Participant.find(params[:id])
      @user_name= session[:user].name
      @user_name = User.find(@student.user_id).name
      @review_mapping = ReviewMapping.find(:all,:conditions => ["author_id = ? and assignment_id = ?", @author_id, @assignment_id])
    end
    @link = @student.submitted_hyperlink
    @files = Array.new
    @files = get_submitted_file_list(@direc, @student, @files)
    
    #the code below finds the sum of the maximum scores of all questions in the questionnaire
    @sum_of_max = 0
    for question in Questionnaire.find(Assignment.find(@assignment_id).review_questionnaire_id).questions
      @sum_of_max += Questionnaire.find(Assignment.find(@assignment_id).review_questionnaire_id).max_question_score
    end
  end
  
  def view_grade
    @author_id = session[:user].id
    @assignment_id = Participant.find(params[:id]).assignment_id
    @review_mapping = ReviewMapping.find(:all,:conditions => ["author_id = ? and assignment_id = ?", @author_id, @assignment_id])   
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

  def submit
    @student = Participant.find(params[:id])
    @link = @student.submitted_hyperlink
    @submission = params[:submission]
    @files = Array.new
    @assignment_id = @student.assignment_id
    # assignment_id below is the ID of the assignment retrieved from the participants table (the assignment in which this student is participating)
    @due_dates = DueDate.find(:all, :conditions => ["assignment_id = ?",@assignment_id])
    @submit_due_date = DueDate.find(:all, :conditions => ["assignment_id = ? and deadline_type_id = ?",@assignment_id,1])
    @resubmission_times = ResubmissionTime.find(:all,:order => "resubmitted_at ASC",:conditions => ["participant_id= ?",@student.id])

    @review_phase = find_review_phase(@due_dates)
    
    #If the student is submitting his work for the first time and is late, the time difference is recorded in the field penalty accumulated in the Participants table
    if Time.now > @submit_due_date[0].due_at and !@resubmission_times[0]
      diff_minutes = (Time.now - @submit_due_date[0].due_at).round/60
      @student.penalty_accumulated += diff_minutes
    end
    
    @current_folder = DisplayOption.new
    @current_folder.name = "/"
    if params[:current_folder]
      @current_folder.name = FileHelper::sanitize_folder(params[:current_folder][:name])
    end
    
    if params['download']
      folder_name = FileHelper::sanitize_folder(@current_folder.name)
      file_name = FileHelper::sanitize_filename(params['download'])
      
      file_split = file_name.split('.')
      if file_split.length > 1 and (file_split[1] == 'htm' or file_split[1] == 'html')
        send_file(get_student_directory(@student) + folder_name + "/" + file_name, :type => Mime::HTML.to_s, :disposition => 'inline') 
      else
        send_file(get_student_directory(@student) + folder_name + "/" + file_name, :disposition => 'inline') 
      end
      
    end
    
    if params['new_folder']
      create_new_folder
    end
    
    if params['upload_link']
      save_weblink
    end
    
    if params['moved_file']
      move_file
    end
    
    if params['copy_file']
      copy_file
    end
    
    if params['new_filename']
      rename_selected_file
    end

    if params['delete_files']
      delete_selected_files
    end
    
    if params['upload_file']
      file = params['uploaded_file']
      puts file

      if @student.directory_num == nil or @student.directory_num < 0
        set_student_directory_num
        #send message to reviewers(s) when submission has been updated
        #ajbudlon, sept 07, 2007
        Assignment.find_by_id(@assignment_id).email(@student.user_id)
      end      
      
      safe_filename = FileHelper::sanitize_filename(file.full_original_filename)
      curr_directory = get_student_directory(@student)+ @current_folder.name
      full_filename =  curr_directory + safe_filename #curr_directory +
      File.open(full_filename, "wb") { |f| f.write(file.read) }
      StudentAssignmentHelper::unzip_file(full_filename, curr_directory, true) if get_file_type(safe_filename) == "zip"
      
      update_resubmit_times
    end
    
    if @student.directory_num != nil and @student.directory_num >= 0
      get_student_folders
      get_student_files 
    end
    
    @review_of_review_mappings = Array.new
    
    @review_mappings_for_author = ReviewMapping.find(:all, :conditions => ["author_id = ?",(session[:user].id)])
    for review_mapping_for_author in @review_mappings_for_author
      if(ReviewOfReviewMapping.find(:first, :conditions => ["review_mapping_id = ?",review_mapping_for_author.id])!= nil)
        puts ReviewOfReviewMapping.find(:first, :conditions => ["review_mapping_id = ?",review_mapping_for_author.id])
        @review_of_review_mappings << ReviewOfReviewMapping.find(:first, :conditions => ["review_mapping_id = ?",review_mapping_for_author.id])
      end
    end
  end
  
  #the final grade report is a page that summarizes all the information an instructor
  #might need to assign a grade for an assignment. Currently it provides all review scores left
  #for an assignment (as well as the comments) and the author feedback (with comments).
  #Support for review of reviews, submission versions and teams still needs to be added.
  def final_grade_report
    @student = Participant.find(params[:id])
    @link = @student.submitted_hyperlink
    @submission = params[:submission]
    @files = Array.new
    @assignment = @student.assignment
    @reviews = Review.find_by_sql("select * from reviews where review_mapping_id in (
          select id from review_mappings where author_id = " + @student.user_id.to_s + 
          " and assignment_id = " + @assignment.id.to_s + ")")       
    @review_feedbacks = ReviewFeedback.find_by_sql("select * from review_feedbacks where 
            author_id = " + @student.user_id.to_s + 
          " and assignment_id = " + @assignment.id.to_s)  
    @current_folder = DisplayOption.new
    @current_folder.name = "/"
    @final_grade = 0
    
    if @student.directory_num != nil and @student.directory_num >= 0
      get_student_folders
      get_student_files 
    end
    
    @files.sort_by { |file| File.mtime(file) }
  end
  
  #this saves the the final grade for a participant of an assignment, as well as saving
  #comments for the student and the instructor. It is called from the final_grade_reports page
  def save_final_grade
    form = params[:participant]
    student = Participant.find(form[:student])
    student.grade = form[:grade]
    student.comments_to_student = form[:student_comments]
    student.private_instructor_comments = form[:non_student_comments]
     
    if student.save
      flash[:note] = 'Final grade was successfully submitted.'
      redirect_to :action => 'final_grade_report', :id => form[:student]
    else
      flash[:notice] = 'An error occured trying to submit the final grade. Please ensure you provided a grade greater than or equal to zero.'
      redirect_to :action => 'final_grade_report', :id => form[:student]
    end
  end

private
  def update_resubmit_times
    new_submit = ResubmissionTime.new(:resubmitted_at => Time.now.to_s)
    @student.resubmission_times << new_submit
  end

  def create_new_folder
    new_folder = FileHelper::sanitize_filename(params[:new_folder])
    if !File.exist?(get_student_directory(@student) + @current_folder.name + "/" + new_folder)
      Dir.mkdir(get_student_directory(@student) + @current_folder.name + "/" + new_folder)
    else 
      flash[:notice] = "Directory name is already taken"
    end
  end
  
  def move_file
    for file_checked in params[:chk_files]
      old_filename = get_student_directory(@student) + @current_folder.name + "/" + params[:filenames][file_checked[0]].to_s
      new_filename = get_student_directory(@student) + FileHelper::sanitize_folder(params[:moved_file])
      file_op "move", old_filename, new_filename
      break
    end
  end
  
  def save_weblink
    
    weblink = params['submission']
    
    if validate(weblink)
      participant = Participant.find(params[:id])   
      participant.submitted_hyperlink = weblink
      participant.save
    end
    redirect_to :action => 'submit'
  end
  
  def validate(url)   
#    begin
#      logger.info "**#{url}**"
#      uri = URI.parse(url)
#    
#      logger.info "**#{uri.class}**"
#      if uri.class != URI::HTTP and uri.class != URI::FTP
#        flash[:error] = "Only HTTP or FTP addresses can be supplied. \n" + url
#        return false
#      end
#    rescue      
#      flash[:error] = "The format of the url is not valid. " + $!
#      return false
#    end
    return true
  end
  
  def copy_file
    for file_checked in params[:chk_files]
      old_filename = get_student_directory(@student) + @current_folder.name + "/" + params[:filenames][file_checked[0]].to_s
      new_filename = get_student_directory(@student) + FileHelper::sanitize_folder(params[:copy_file])
      if File.exist?(old_filename)
        file_op "copy", old_filename, new_filename
      else
        flash[:notice] = "File does not exist"
      end
      break
    end
  end

  def rename_selected_file
    for file_checked in params[:chk_files]
      old_filename = get_student_directory(@student) + @current_folder.name + "/" + params[:filenames][file_checked[0]].to_s
      new_filename = get_student_directory(@student) + @current_folder.name + "/" + FileHelper::sanitize_filename(params[:new_filename])
      file_op "rename", old_filename, new_filename
      break
    end
  end

  def file_op action, old_filename, new_filename
    begin
      if !File.exist?(new_filename)
        flash[:notice] = ""
        File.send(action, old_filename, new_filename)
      else
        # Filename is already taken
        flash[:notice] = "Filename is already in use"
      end
    rescue
      # The path of the file had an invalid directory
      flash[:notice] = "No such folder exists"
    end
  end

  def delete_selected_files
    if params[:chk_files] != nil
      for file_checked in params[:chk_files]
        # Loop through all the selected files and delete them
        filename = params[:filenames][file_checked[0]].to_s
        File.delete(get_student_directory(@student) + @current_folder.name + "/" + filename)
      end
    end
  end

  def set_student_directory_num
    # Student has not submitted a file yet, so the directory_num
    # needs to be set before saving the file
    participants = Participant.find(:all,
                                   :conditions => "assignment_id = #{@student.assignment_id}",
                                   :order => "directory_num DESC")
    if participants == nil or participants.size == 0
      @student.directory_num = 0
    elsif participants != nil
      if participants[0].directory_num != nil
        @student.directory_num = participants[0].directory_num + 1
      else
        @student.directory_num = 0
      end
    end     
    @student.save 
    create_student_directory
  end

  def get_student_directory(participant)
    # This assumed that the directory num has already been set
    return RAILS_ROOT + "/pg_data/" + participant.assignment.directory_path + "/" + participant.directory_num.to_s
  end

  def create_student_directory
    print "\n\n" + get_student_directory(@student)
    Dir.mkdir(get_student_directory(@student))
  end

  def get_student_files
    temp_files = Dir[get_student_directory(@student) + @current_folder.name + "/*"]
    for file in temp_files
      if not File.directory?(Dir.pwd + "/" + file) then
        @files << file
      end
    end
    return @files
  end
  
  def get_student_folders
    temp_files = Dir[get_student_directory(@student) + "/*"]
    @folders = Array.new
    @folders << "/"
    for file in temp_files
      if File.directory?(Dir.pwd + "/" + file) then
        @folders << file.gsub(get_student_directory(@student), "")
        find_student_folders file
      end
    end
  end
  
  def find_student_folders dir
    # Find all the subfolders recursively
    temp_files = Dir[dir + "/*"]
    for file in temp_files
      if File.directory?(file) then
        @folders << file.gsub(get_student_directory(@student), "")
        find_student_folders file
      end
    end
  end
  
    def find_viewing_permissions(due_dates)
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

      if next_due_date.submission_allowed_id == 2 or next_due_date.submission_allowed_id == 3
        @can_view_your_work =1
      end
      if next_due_date.review_allowed_id == 2 or next_due_date.review_allowed_id == 3
        @can_view_others_work =1
      end

      if next_due_date.resubmission_allowed_id == 2 or next_due_date.resubmission_allowed_id == 3
        @can_view_your_work =1
      end

      if next_due_date.rereview_allowed_id == 2 or next_due_date.rereview_allowed_id == 3
        @can_view_others_work =1
      end

      if next_due_date.review_of_review_allowed_id == 2 or next_due_date.review_of_review_allowed_id == 3
        @can_view_others_work =1
      end

    return [@can_view_your_work, @can_view_others_work]
  end
  
  def get_file_type file_name
    base = File.basename(file_name)
	  if base.split(".").size > 1
      return base.split(".")[base.split(".").size-1]
	  end
	end
  
  def get_submitted_file_list(direc,author,files)
    if(author!=nil && author.directory_num)
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
  
end