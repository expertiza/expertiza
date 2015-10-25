class SubmittedContentController < ApplicationController
  helper :wiki

  def action_allowed?
    ['Instructor',
       'Teaching Assistant',
       'Administrator',
       'Super-Administrator',
       'Student'].include? current_role_name and ((%w(edit).include? action_name) ? are_needed_authorizations_present? : true) and one_team_can_submit_work?
  end

  #The view have already tested that @assignment.submission_allowed(topic_id) is true,
  # so @can_submit should be true
  def edit
    @participant = AssignmentParticipant.find(params[:id])
    return unless current_user_id?(@participant.user_id)

    @assignment = @participant.assignment

    #ACS We have to check if this participant has team or not
    #hence use team count for the check
    if @participant.team.nil?
      #flash[:error] = "This is a team assignment. Before submitting your work, you must <a style='color: blue;' href='../../student_teams/view/?student_id=#{params[:id]}'>create a team</a>, even if you will be the only member of the team"
      #redirect_to :controller => 'student_task', :action => 'view', :id => params[:id]
      SignUpSheet.signup_team(@assignment.id, @participant.user_id, nil)
    end

    #@can_submit is the flag indicating if the user can submit or not in current stage
    @can_submit=true

    @stage = @assignment.get_current_stage(SignedUpTeam.topic_id(@participant.parent_id, @participant.user_id))
  end

  #view is called when @assignment.submission_allowed(topic_id) is false
  #so @can_submit should be false
  def view
    @participant = AssignmentParticipant.find(params[:id])
    return unless current_user_id?(@participant.user_id)

    @assignment = @participant.assignment

    #@can_submit is the flag indicating if the user can submit or not in current stage
    @can_submit=false

    @stage = @assignment.get_current_stage(SignedUpTeam.topic_id(@participant.parent_id, @participant.user_id))
    redirect_to action: 'edit', id:params[:id]
  end

def submit_hyperlink
  @participant = AssignmentParticipant.find(params[:id])
  return unless current_user_id?(@participant.user_id)

  team_hyperlinks = @participant.hyperlinks
  if team_hyperlinks.include?(params['submission'])
    flash[:error] = "You or your teammate(s) have already submitted the same hyperlink."
  else
    begin
      @participant.submit_hyperlink(params['submission'])
      @participant.update_resubmit_times
    rescue
      flash[:error] = "The URL or URI is not valid. Reason: #{$!}"
    end
    undo_link("Link has been submitted successfully. ")
  end
  redirect_to :action => 'edit', :id => @participant.id
end

# Note: This is not used yet in the view until we all decide to do so
def remove_hyperlink
  @participant = AssignmentParticipant.find(params[:hyperlinks][:participant_id])

  return unless current_user_id?(@participant.user_id)
  hyperlink_to_delete = @participant.hyperlinks[params['chk_links'].to_i]

  team_id = TeamsUser.team_id(@participant.parent_id, @participant.user_id)
  team_participants = Array.new
  if Team.exists?(team_id)
    team_users = TeamsUser.where(team_id: team_id)
    team_users.each do |team_user|
      team_participants << AssignmentParticipant.where(parent_id: @participant.parent_id, user_id: team_user.user_id).first
    end
  else
    team_participants << @participant
  end

  team_participants.each do |team_participant|
    team_participant.remove_hyperlink(hyperlink_to_delete)
  end

  undo_link("Link has been removed successfully. ")

  #determine if the user should be redirected to "edit" or  "view" based on the current deadline right
  topic_id = SignedUpTeam.topic_id(@participant.parent_id, @participant.user_id)
  assignment = Assignment.find(@participant.parent_id)

  if assignment.submission_allowed(topic_id)
    redirect_to :action => 'edit', :id => @participant.id
  else
    redirect_to :action => 'view', :id => @participant.id
  end
end

def submit_file
  participant = AssignmentParticipant.find(params[:id])
  return unless current_user_id?(participant.user_id)

  file = params[:uploaded_file]
  participant.set_student_directory_num

  @current_folder = DisplayOption.new
  @current_folder.name = "/"
  if params[:current_folder]
    @current_folder.name = FileHelper::sanitize_folder(params[:current_folder][:name])
  end
  if params[:origin] == 'review'
    curr_directory = participant.review_file_path(params[:response_map_id]).to_s + @current_folder.name
  else
    curr_directory = participant.path.to_s + @current_folder.name
  end
  if !File.exists? curr_directory
    FileUtils.mkdir_p(curr_directory)
  end
  safe_filename = file.original_filename.gsub(/\\/,"/")
  safe_filename = FileHelper::sanitize_filename(safe_filename) # new code to sanitize file path before upload*
    full_filename =  curr_directory + File.split(safe_filename).last.gsub(" ",'_') #safe_filename #curr_directory +
    File.open(full_filename, "wb") { |f| f.write(file.read) }
  if params['unzip']
    SubmittedContentHelper::unzip_file(full_filename, curr_directory, true) if get_file_type(safe_filename) == "zip"
  end
  participant.update_resubmit_times

  #send message to reviewers when submission has been updated
  participant.assignment.email(participant.id) rescue nil # If the user has no team: 1) there are no reviewers to notify; 2) calling email will throw an exception. So rescue and ignore it.
  if params[:origin] == 'review'
    redirect_to :back
  else
    redirect_to :action => 'edit', :id => participant.id
  end
end


def folder_action
  @participant = AssignmentParticipant.find(params[:id])
  return unless current_user_id?(@participant.user_id)

  @current_folder = DisplayOption.new
  @current_folder.name = "/"
  if params[:current_folder]
    @current_folder.name = FileHelper::sanitize_folder(params[:current_folder][:name])
  end
  if params[:faction][:delete]
    delete_selected_files
  elsif params[:faction][:rename]
    rename_selected_file
  elsif params[:faction][:move]
    move_selected_file
  elsif params[:faction][:copy]
    copy_selected_file
  elsif params[:faction][:create]
    create_new_folder
  end

  redirect_to :action => 'edit', :id => @participant.id
end

def download
  #folder_name = FileHelper::sanitize_folder(@current_folder.name)
  folder_name = params['current_folder']['name']
  # -- This code removed on 4/10/09 ... was breaking downloads of files with hyphens in them ...file_name = FileHelper::sanitize_filename(params['download'])
  file_name = params['download']

  file_split = file_name.split('.')
  if file_split.length > 1 and (file_split[1] == 'htm' or file_split[1] == 'html')
    send_file(folder_name+ "/" + file_name, :disposition => 'inline')
  else
    if !File.directory?(folder_name + "/" + file_name)
      file_ext = File.extname(file_name)[1..-1]
      file_ext = 'bin' if file_ext.blank? # default to application/octet-stream
      send_file folder_name + "/" + file_name,
        :disposition => 'inline'
    else
      raise "Directory downloads are not supported"
    end
  end
end

# This was written for a custom rubric used by Dr. Jennifer Kidd (ODU)
# Note that the file that is being uploaded here is a REVIEW, not submitted work.
def custom_submit_file

  begin
    file = params[:uploaded_file]
    participant = Participant.find(params[:participant_id])

    @current_folder = DisplayOption.new
    @current_folder.name = "/"
    if params[:current_folder]
      @current_folder.name = FileHelper::sanitize_folder(params[:current_folder][:name])
    end

    curr_directory = participant.assignment.path.to_s+ "/" +params[:map].to_s + @current_folder.name
    if !File.exists? curr_directory
      FileUtils.mkdir_p(curr_directory)
    else
      FileUtils.rm_rf(curr_directory)
      FileUtils.mkdir_p(curr_directory)
    end

    safe_filename = file.original_filename.gsub(/\\/,"/")
    safe_filename = FileHelper::sanitize_filename(safe_filename) # new code to sanitize file path before upload*
      full_filename =  curr_directory + File.split(safe_filename).last.gsub(" ",'_') #safe_filename #curr_directory +
      File.open(full_filename, "wb") { |f| f.write(file.read) }
  rescue
  end

  if params[:return_to] == "edit"
    redirect_to :controller=>'response', :action => params[:return_to], :id => params[:id]
  else
    redirect_to :controller=>'response', :action => params[:return_to], :id => params[:map]
  end
end

private

def get_file_type file_name
  base = File.basename(file_name)
  if base.split(".").size > 1
    return base.split(".")[base.split(".").size-1]
  end
end


def move_selected_file
  old_filename = params[:directories][params[:chk_files]] + "/" + params[:filenames][params[:chk_files]]
  newloc = @participant.dir_path
  newloc += "/"
  newloc += params[:faction][:move]
  begin
    FileHelper::move_file(old_filename, newloc)
    flash[:note] = "The file was moved successfully from \"/#{params[:filenames][params[:chk_files]]}\" to \"/#{params[:faction][:move]}\""
  rescue
    flash[:error] = "There was a problem moving the file: "+$!
    end
end

def rename_selected_file
  old_filename = params[:directories][params[:chk_files]] +"/"+ params[:filenames][params[:chk_files]]
  new_filename = params[:directories][params[:chk_files]] +"/"+ FileHelper::sanitize_filename(params[:faction][:rename])
  begin
    if !File.exist?(new_filename)
      File.send("rename", old_filename, new_filename)
    else
      raise "A file already exists in this directory with the name \"#{params[:faction][:rename]}\""
    end
  rescue
    flash[:error] = "There was a problem renaming the file: "+$!
  end
end

def delete_selected_files
  filename = params[:directories][params[:chk_files]] +"/"+ params[:filenames][params[:chk_files]]
  FileUtils.rm_r(filename)
end

def copy_selected_file
  old_filename = params[:directories][params[:chk_files]] +"/"+ params[:filenames][params[:chk_files]]
  new_filename = params[:directories][params[:chk_files]] +"/"+ FileHelper::sanitize_filename(params[:faction][:copy])
  begin
    if File.exist?(new_filename)
      raise "A file with this name already exists. Please delete the existing file before copying."
    end

    if File.exist?(old_filename)
      FileUtils.cp_r(old_filename, new_filename)
    else
      raise "The referenced file does not exist."
    end
  rescue
    flash[:error] = "There was a problem copying the file: "+$!
  end
end

def create_new_folder
  newloc = @participant.dir_path
  newloc += "/"
  newloc += params[:faction][:create]
  begin
    FileHelper::create_directory_from_path(newloc)
    flash[:note] = "The directory #{params[:faction][:create]} was created."
  rescue
    flash[:error] = $!
  end
end

#def undo_link
#  "<a href = #{url_for(:controller => :versions,:action => :revert,:id => @participant.versions.last.id)}>undo</a>"
#end
  
  private
  #authorizations: reader,submitter, reviewer
  def are_needed_authorizations_present?
    @participant = Participant.find(params[:id])
    authorization = Participant.get_authorization(@participant.can_submit, @participant.can_review, @participant.can_take_quiz)
    if authorization == 'reader' or authorization == 'reviewer'
      return false
    else
      return true
    end
  end

  #if one team do not hold a topic (still in waitlist), they cannot submit their work.
  def one_team_can_submit_work?
    if params[:id].nil?
      @participant = AssignmentParticipant.find(params[:hyperlinks][:participant_id])
    else
      @participant = AssignmentParticipant.find(params[:id])
    end
    @topics = SignUpTopic.where(assignment_id: @participant.parent_id)
    #check one assignment has topics or not
    if (@topics.size > 0 and !SignedUpTeam.topic_id(@participant.parent_id, @participant.user_id).nil?) or @topics.size == 0
      return true
    else
      return false
    end
  end
end
