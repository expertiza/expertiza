require 'zip/zip'
require 'uri'

class StudentAssignmentController < ApplicationController
  helper :wiki
  helper :student_assignment	
  helper :google
  auto_complete_for :user, :name
  
#  def auto_complete_for_user_name
#    search = params[:user][:name].to_s
#    @users = User.find_by_sql("select * from users where id !="+session[:user].id.to_s+" and LOWER(name) LIKE '%"+search+"%' and id in (select user_id from participants where parent_id = "+session[:dummy][:assignment_id]+")")
#    render :inline => "<%= auto_complete_result @users, 'name' %>", :layout => false
#  end
  
  def view_team
    @student = AssignmentParticipant.find(params[:id])
    @teams = AssignmentTeam.find_all_by_parent_id(@student.parent_id)
    for team in @teams
      @teamuser = TeamsUser.find(:first, :conditions => ['team_id = ? and user_id = ?', team.id, @student.user_id])
      if @teamuser != nil
        @team_id = @teamuser.team_id
      end
    end
    
    @team_members = TeamsUser.find(:all, :conditions => ['team_id = ?', @team_id])
    @send_invs = Invitation.find(:all, :conditions => ['from_id = ? and assignment_id = ?', @student.user_id, @student.parent_id])
    @received_invs = Invitation.find(:all, :conditions => ['to_id = ? and assignment_id = ? and reply_status = "W"', @student.user_id, @student.parent_id])
  end
  
  def list
    user_id = session[:user].id
    @user =session[:user]
    @participants = AssignmentParticipant.find_all_by_user_id(user_id, :order => "parent_id DESC")
  end
  
  def view_publishing
    user_id = session[:user].id
    @user =session[:user]
    @participants = AssignmentParticipant.find(:all, 
                                    :conditions => ['user_id = ?', user_id],
                                    :order => "parent_id DESC")
  end
  
  def view_actions
    @student = AssignmentParticipant.find(params[:id])
    @assignment_id = @student.parent_id
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
    @participant = AssignmentParticipant.find(:first, :conditions => ["id = ?",params[:participant]])
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
    @participant = AssignmentParticipant.find(:first, :conditions => ["id = ?",params[:participant]])
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
    @participants = AssignmentParticipant.find(:all, :conditions => ["user_id = ?",params[:user]])
    for participant in @participants
      participant.permission_granted = 1;
      if !participant.save
        render :action => 'view_publishing'
      end
    end
    redirect_to :action => 'view_publishing'
  end
  
  def set_all_publish_permission_no
    @participants = AssignmentParticipant.find(:all, :conditions => ["user_id = ?",params[:user]])
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
    @assignment_id = AssignmentParticipant.find(params[:id]).parent_id
    @assignment = Assignment.find(@assignment_id)
    if @assignment.team_assignment
      @team_id = TeamsUser.find(:first,:conditions => ["user_id=? and team_id in (select id from teams where parent_id=?)", @author_id, @assignment_id]).team_id
      @author_first_user_id = TeamsUser.find(:first,:conditions => ["team_id=?", @team_id]).user_id
      @student = AssignmentParticipant.find(:first,:conditions => ["user_id = ? AND parent_id = ?", @author_first_user_id, @assignment_id])
      @user_name= session[:user].name
      #@user_name = User.find(@author_first_user_id).name
      @review_mapping = ReviewMapping.find(:all,:conditions => ["team_id = ? and assignment_id = ?", @team_id, @assignment_id])
    else
      @student = AssignmentParticipant.find(params[:id])
      @user_name= session[:user].name
      @review_mapping = ReviewMapping.find(:all,:conditions => ["author_id = ? and assignment_id = ?", session[:user].id, @assignment_id])
    end
    @late_policy = LatePolicy.find(1)
    # removed until late policies are implemented
    #late_policy = LatePolicy.find(Assignment.find(@assignment_id).due_dates[0].late_policy_id)
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

    for review_mapping_for_author in @review_mapping
      if(ReviewOfReviewMapping.find(:first, :conditions => ["review_mapping_id = ?",review_mapping_for_author.id])!= nil)
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
      @review_feedback.txt = text
      @review_feedback.update
    else
      @review_feedback = ReviewFeedback.new
      @review_feedback.review_id = review_id
      @review_feedback.assignment_id = assignment_id
      @review_feedback.txt = text
      if @review_feedback.save
        flash[:notice] = 'feedback has been updated'
      end
    end
  end
  
  def view_feedback
    @author_id = session[:user].id
    @student =  AssignmentParticipant.find(params[:id])
    @assignment_id = @student.parent_id
    @assignment = Assignment.find(@assignment_id)
     if @assignment.team_assignment 
      @team_id = TeamsUser.find(:first,:conditions => ["user_id=? and team_id in (select id from teams where parent_id=?)", @author_id, @assignment_id]).team_id
      @team_members = TeamsUser.find(:all,:conditions => ["user_id=? and team_id in (select id from teams where parent_id=?)", @author_id, @assignment_id])
      @author_first_user_id = TeamsUser.find(:first,:conditions => ["team_id=?", @team_id]).user_id
      @user_name= session[:user].name
      #@user_name = User.find(@author_first_user_id).name
      @review_mapping = ReviewMapping.find(:all,:conditions => ["team_id = ? and assignment_id = ?", @team_id, @assignment_id])
    elsif !@assignment.team_assignment
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

    @current_folder = DisplayOption.new
    @current_folder.name = "/"
    if params[:current_folder]
       @current_folder.name = FileHelper::sanitize_folder(params[:current_folder][:name])
    end

    if params['fname']
      view_submitted_file(@current_folder,@student)
    end
  end
  
  def view_grade
    @author_id = session[:user].id
    @assignment_id = AssignmentParticipant.find(params[:id]).parent_id
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
    @student = AssignmentParticipant.find(params[:id])
    @link = @student.submitted_hyperlink
    @submission = params[:submission]
    @files = Array.new
    @assignment_id = @student.parent_id
    
    # Return URI depending on link type.
    @assignment = Assignment.find(@assignment_id)
    if @assignment.is_google_doc
      @link = google_id_to_url(@student.submitted_hyperlink)
    else
      @link = @student.submitted_hyperlink
    end
    
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
      #folder_name = FileHelper::sanitize_folder(@current_folder.name)
      folder_name = params['current_folder']['name']
      file_name = FileHelper::sanitize_filename(params['download'])
            
      file_split = file_name.split('.')
      if file_split.length > 1 and (file_split[1] == 'htm' or file_split[1] == 'html')
        #send_file(get_student_directory(@student) + folder_name + file_name, :type => Mime::HTML.to_s, :disposition => 'inline') 
        send_file(folder_name+ "/" + file_name, :type => Mime::HTML.to_s, :disposition => 'inline')
      else
        #send_file(get_student_directory(@student) + folder_name + file_name, :disposition => 'inline') 
        if !File.directory?(folder_name + "/" + file_name)
          send_file( folder_name + "/" + file_name, :disposition => 'inline')
    else
    #StudentAssignmentHelper::zip_file(folder_name + "/" + file_name, folder_name, file_name)
    #send_file( folder_name + "/" + file_name+ ".zip", :disposition => 'inline')
    #FileUtils.rm_r (folder_name + "/" + file_name+ ".zip")
    Net::SFTP.start("http://pg-server.csc.ncsu.edu", "*****", "****") do |sftp|
           sftp.download!(folder_name + "/" + file_name, "C:/expertiza", :recursive => true)
    end
        end
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
      #@student.set_student_directory_num
      
      if @student.directory_num == nil or @student.directory_num < 0
        set_student_directory_num
      end  
        #send message to reviewers(s) when submission has been updated
        #ajbudlon, sept 07, 2007
      logger.info "Sending submission e-mail"    
      Assignment.find_by_id(@assignment_id).email(@student.user_id)
      #end      
      #safe_filename = FileHelper::sanitize_filename(file.full_original_filename)
      if @assignment.team_assignment
    curr_directory = @student.get_path.to_s+ @current_folder.name
      else
    curr_directory = @student.get_path.to_s+ @current_folder.name
      end

      if !File.exists? curr_directory
         FileUtils.mkdir_p(curr_directory)
      end
      safe_filename = file.full_original_filename.gsub(/\\/,"/")
      safe_filename = FileHelper::sanitize_filename(safe_filename) # new code to sanitize file path before upload*
      full_filename =  curr_directory + File.split(safe_filename).last.gsub(" ",'_') #safe_filename #curr_directory +
      File.open(full_filename, "wb") { |f| f.write(file.read) }
      if params['unzip']
  StudentAssignmentHelper::unzip_file(full_filename, curr_directory, true) if get_file_type(safe_filename) == "zip"
      end
      update_resubmit_times
    end
    
    if @student.directory_num != nil and @student.directory_num >= 0
      get_student_folders
      get_student_files 
    end
    
    @review_of_review_mappings = Array.new
    
    @review_mappings_for_author = ReviewMapping.find(:all, :conditions => ["author_id = ? and assignment_id = ?",session[:user].id,@assignment_id])
    for review_mapping_for_author in @review_mappings_for_author
      if(ReviewOfReviewMapping.find(:first, :conditions => ["review_mapping_id = ?",review_mapping_for_author.id])!= nil)
        @review_of_review_mappings << ReviewOfReviewMapping.find(:first, :conditions => ["review_mapping_id = ? ",review_mapping_for_author.id])
      end
    end
  end

private

    
  # Converts a document ID to a fully qualified HTTP URL. This is
  # done for maintainability, since the URL format of Google Docs
  # may change in the future.
  def google_id_to_url(doc_id)
    return "http://docs.google.com/View?docid=#{doc_id}"
  end
  
  def update_resubmit_times
    new_submit = ResubmissionTime.new(:resubmitted_at => Time.now.to_s)
    @student.resubmission_times << new_submit
  end

  def create_new_folder
    new_folder = params[:new_folder]
    if !File.exist?(@student.get_path + @current_folder.name + "/" + new_folder)
      FileUtils.mkdir_p(@student.get_path + @current_folder.name + "/" + new_folder)
    else 
      flash[:notice] = "Directory name is already taken"
    end
  end
  
  def move_file
    old_filename = params[:filenames][params[:chk_files]].to_s
        new_filename = @student.get_path + (params[:moved_file])
        #if (file_op "mv", old_filename, new_filename)
  FileUtils.mv old_filename, new_filename, :force => true
        #end  
  end
  
  def save_weblink
    weblink = params['submission']
    if check_validity(weblink.strip)
      if @assignment.team_assignment
  teams_member = TeamsUser.find_by_sql("select * from teams_users where team_id in (select team_id from teams_users where user_id="+session[:user].id.to_s+") and team_id in (select id from teams where parent_id="+@assignment_id.to_s+")")
    teams_member.each{
        |member|
        participant = Participant.find(:first, :conditions => ['user_id = ? and parent_id = ?', member.user_id, @assignment.id])
        participant.submitted_hyperlink = weblink
  participant.save
     }

      else
        participant = Participant.find(params[:id])   
      participant.submitted_hyperlink = weblink
      participant.save
      end
    end
    redirect_to :action => 'submit'
  end
  
  def check_validity(url)   
    #begin 
      if /(^$)|(^(http|https|ftp):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix.match(url)
        return true
      else
      flash[:error] = "The format of the url is not valid. Only HTTP or FTP addresses can be supplied. "
        return false
      end
    #rescue      
    #  flash[:error] = "The format of the url is not valid. Only HTTP or FTP addresses can be supplied. " + $!
    #  return false
    #end
    return true
  end
  
  def copy_file
    old_filename = params[:filenames][params[:chk_files]].to_s
        new_filename = @student.get_path + params[:copy_file]
        if File.exist?(old_filename)
          #if (file_op "cp_r", old_filename, new_filename)
    FileUtils.cp_r old_filename, new_filename 
    #end
        else
          flash[:notice] = "File does not exist"
        end
  end

  def rename_selected_file
    old_filename = params[:filenames][params[:chk_files]].to_s
        new_filename = File.dirname(params[:filenames][params[:chk_files]]) + "/" + FileHelper::sanitize_filename(params[:new_filename])
        if (file_op "rename", old_filename, new_filename)
    File.send("rename", old_filename, new_filename)
    end 
  end

  def file_op action, old_filename, new_filename
    begin
      if !File.exist?(new_filename)
        flash[:notice] = ""
        #File.send(action, old_filename, new_filename)
  return true
      else
        # Filename is already taken
        flash[:notice] = "Filename is already in use"+$!
      end
    rescue
      # The path of the file had an invalid directory
      flash[:notice] = "No such folder exists or filename is already in use"
    end
  end

  def delete_selected_files
    filename = params[:filenames][params[:chk_files]].to_s
        FileUtils.rm_r(filename)
  end

  def set_student_directory_num
    # If a student or team member has not submitted anything
    # a directory number needs to be assigned to the participants
    # this is done by determining the last directory number 
    # created and incrementing it.

    participants = Participant.find(:all, :conditions => ['parent_id = ?',@assignment_id], :order => 'directory_num DESC')
    instructor = User.find(@assignment.instructor_id).name
    if participants != nil and participants[0].directory_num != nil
      if @assignment.team_assignment
         @student.directory_num = participants[0].directory_num + 1
         assign_team_directories (participants[0].directory_num + 1)
         if Dir[RAILS_ROOT + "/pg_data/" + instructor + "/" +@assignment.directory_path+ "/" +@student.directory_num.to_s] != nil  
          Dir.mkdir (RAILS_ROOT + "/pg_data/" + instructor + "/" + @assignment.directory_path+ "/" +@student.directory_num.to_s) 
  end
      else
         @student.directory_num = participants[0].directory_num + 1
      end
    else
      if @assignment.team_assignment
         Dir.mkdir (RAILS_ROOT + "/pg_data/" + instructor + "/" + @assignment.directory_path+ "/0")
         @student.directory_num = 0
         assign_team_directories(0)
      else
         @student.directory_num = 0
      end
    end
  end

  def assign_team_directories(dir_num)
    # handles a team assignment so that each member
    # of the team has the same submission directory
    teams_member = TeamsUser.find_by_sql("select * from teams_users where team_id in (select team_id from teams_users where user_id="+session[:user].id.to_s+") and team_id in (select id from teams where parent_id="+@assignment_id.to_s+")")
    teams_member.each{
        |member| 
        participant = Participant.find(:first, :conditions => ['user_id = ? and parent_id = ?', member.user_id, @assignment.id])
  participant.directory_num = dir_num
  participant.save
     }
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
    temp_files = Dir[@student.get_path + @current_folder.name + "/*"]
    for file in temp_files
      if not File.directory?(Dir.pwd + "/" + file) then
        @files << file
      end
    end
    return @files
  end
  def get_submitted_file_list(direc,author,files)
    if(author!=nil && author.directory_num)
      direc = @student.get_path
      temp_files = Dir[direc + "/*"]
      for file in temp_files
        if not File.directory?(Dir.pwd + "/" + file) then
          files << file
        end
      end
    end
    return files
  end

  def get_student_folders
    temp_files = Dir[@student.get_path + "/*"]
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

      if next_due_date.submission_allowed_id == LATE or next_due_date.submission_allowed_id == OK
        @can_view_your_work = true
      end
      if next_due_date.review_allowed_id == LATE or next_due_date.review_allowed_id == OK 
        @can_view_others_work = true
      end

      if next_due_date.resubmission_allowed_id == LATE or next_due_date.resubmission_allowed_id == OK
        @can_view_your_work = true
      end

      if next_due_date.rereview_allowed_id == LATE or next_due_date.rereview_allowed_id == OK
        @can_view_others_work = true
      end

      if next_due_date.review_of_review_allowed_id == LATE or next_due_date.review_of_review_allowed_id == OK
        @can_view_others_work = true
      end

    return [@can_view_your_work, @can_view_others_work]
  end
  
  def get_file_type file_name
    base = File.basename(file_name)
    if base.split(".").size > 1
      return base.split(".")[base.split(".").size-1]
    end
  end
  def view_submitted_file(current_folder,author)
    folder_name = FileHelper::sanitize_folder(current_folder.name)
    file_name = FileHelper::sanitize_filename(params['fname'])
    file_split = file_name.split('.')
    fullfilename = RAILS_ROOT + "/pg_data/" + author.assignment.directory_path + "/" + author.directory_num.to_s + folder_name + "/" + file_name
    if file_split.length > 1 and (file_split[1] == 'htm' or file_split[1] == 'httml')
      send_file(fullfilename, :type => Mime::THML.to_s, :disposition => 'inline')
    else
      send_file(fullfilename)
    end
  end
  
end