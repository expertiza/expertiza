class SubmittedContentController < ApplicationController
  def action_allowed?
    ['Instructor',
     'Teaching Assistant',
     'Administrator',
     'Super-Administrator',
     'Student'].include? current_role_name and 
    ((%w(edit).include? action_name) ? are_needed_authorizations_present?(params[:id], "reader", "reviewer") : true) and
    one_team_can_submit_work?
  end

  # The view have already tested that @assignment.submission_allowed(topic_id) is true,
  # so @can_submit should be true
  def edit
    @participant = AssignmentParticipant.find(params[:id])
    return unless current_user_id?(@participant.user_id)

    @assignment = @participant.assignment

    # ACS We have to check if this participant has team or not
    # hence use team count for the check
    if @participant.team.nil?
      # flash[:error] = "This is a team assignment. Before submitting your work, you must <a style='color: blue;' href='../../student_teams/view/?student_id=#{params[:id]}'>create a team</a>, even if you will be the only member of the team"
      # redirect_to :controller => 'student_task', :action => 'view', :id => params[:id]
      SignUpSheet.signup_team(@assignment.id, @participant.user_id, nil)
    end

    # @can_submit is the flag indicating if the user can submit or not in current stage
    if params.has_key?(:view)
      @can_submit = false
    else
      @can_submit = true
    end

    @stage = @assignment.get_current_stage(SignedUpTeam.topic_id(@participant.parent_id, @participant.user_id))
  end

  # view is called when @assignment.submission_allowed(topic_id) is false
  # so @can_submit should be false
  def view
    @participant = AssignmentParticipant.find(params[:id])
    return unless current_user_id?(@participant.user_id)

    @assignment = @participant.assignment

    # @can_submit is the flag indicating if the user can submit or not in current stage
    @can_submit = false

    @stage = @assignment.get_current_stage(SignedUpTeam.topic_id(@participant.parent_id, @participant.user_id))
    redirect_to action: 'edit', id: params[:id], view: true
  end

  def submit_hyperlink

    @participant = AssignmentParticipant.find(params[:id])
    return unless current_user_id?(@participant.user_id)

    team = @participant.team
    team_hyperlinks = team.hyperlinks
    if team_hyperlinks.include?(params['submission'])
      flash[:error] = "You or your teammate(s) have already submitted the same hyperlink."
    else
      begin
        team.submit_hyperlink(params['submission'])

        #create a submission record
        @submission_record = SubmissionRecord.new(team_id: team.id, content: params['submission'], user: @participant.name, assignment_id: params[:id], operation: "Submit Hyperlink")
        @submission_record.save
      rescue
        flash[:error] = "The URL or URI is not valid. Reason: #{$ERROR_INFO}"
      end
      undo_link("The link has been successfully submitted.")
    end
    redirect_to action: 'edit', id: @participant.id
  end

  # Note: This is not used yet in the view until we all decide to do so
  def remove_hyperlink

    @participant = AssignmentParticipant.find(params[:hyperlinks][:participant_id])
    return unless current_user_id?(@participant.user_id)

    team = @participant.team
    hyperlink_to_delete = team.hyperlinks[params['chk_links'].to_i]
    team.remove_hyperlink(hyperlink_to_delete)

    undo_link("The link has been successfully removed.")

    # determine if the user should be redirected to "edit" or  "view" based on the current deadline right
    topic_id = SignedUpTeam.topic_id(@participant.parent_id, @participant.user_id)
    assignment = Assignment.find(@participant.parent_id)

    #create a submission record
    @submission_record = SubmissionRecord.new(team_id: team.id, content: hyperlink_to_delete, user:@participant.name , assignment_id: assignment.id, operation: "Remove Hyperlink")
    @submission_record.save


    if assignment.submission_allowed(topic_id)
      redirect_to action: 'edit', id: @participant.id
    else
      redirect_to action: 'view', id: @participant.id
    end
  end

  def submit_file

    participant = AssignmentParticipant.find(params[:id])
    return unless current_user_id?(participant.user_id)


    file = params[:uploaded_file]
    participant.team.set_student_directory_num

    @current_folder = DisplayOption.new
    @current_folder.name = "/"
    if params[:current_folder]
      @current_folder.name = FileHelper.sanitize_folder(params[:current_folder][:name])
    end
    curr_directory = if params[:origin] == 'review'
                       participant.review_file_path(params[:response_map_id]).to_s + @current_folder.name
                     else
                       participant.team.path.to_s + @current_folder.name
                     end
    FileUtils.mkdir_p(curr_directory) unless File.exist? curr_directory
    safe_filename = file.original_filename.tr('\\', "/")
    safe_filename = FileHelper.sanitize_filename(safe_filename) # new code to sanitize file path before upload*
    full_filename = curr_directory + File.split(safe_filename).last.tr(" ", '_') # safe_filename #curr_directory +
    File.open(full_filename, "wb") {|f| f.write(file.read) }
    if params['unzip']
      SubmittedContentHelper.unzip_file(full_filename, curr_directory, true) if get_file_type(safe_filename) == "zip"
    end

    #create a submission record
    assignment = Assignment.find(participant.parent_id)
    team = participant.team
    @submission_record = SubmissionRecord.new(team_id: team.id, content: full_filename, user: participant.name , assignment_id: assignment.id, operation: "Submit File")
    @submission_record.save

   # params = ActionController::Parameters.new(a: "123", b: "456")
    # send message to reviewers when submission has been updated
    participant.assignment.email(participant.id) rescue nil # If the user has no team: 1) there are no reviewers to notify; 2) calling email will throw an exception. So rescue and ignore it.
    if params[:origin] == 'review'
      redirect_to :back
    else
      redirect_to action: 'edit', id: participant.id
    end
  end

  def folder_action
    @participant = AssignmentParticipant.find(params[:id])
    return unless current_user_id?(@participant.user_id)

    @current_folder = DisplayOption.new
    @current_folder.name = "/"
    if params[:current_folder]
      @current_folder.name = FileHelper.sanitize_folder(params[:current_folder][:name])
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

    redirect_to action: 'edit', id: @participant.id
  end

  def download
    begin
      # folder_name = FileHelper::sanitize_folder(@current_folder.name)
      folder_name = params['current_folder']['name']
      # -- This code removed on 4/10/09 ... was breaking downloads of files with hyphens in them ...file_name = FileHelper::sanitize_filename(params['download'])
      file_name = params['download']
      if folder_name.nil?
        raise "Folder_name is nil."
      elsif file_name.nil?
        raise "File_name is nil."
      elsif File.directory?(folder_name + "/" + file_name)
        raise "Cannot send a whole folder."
      elsif !File.exist?(folder_name + "/" + file_name)
        rails "File does not exist."
      else
        send_file(folder_name + "/" + file_name, disposition: 'inline')
      end
    rescue => e
      flash[:error] = e.message
    end
  end

  private

  def get_file_type file_name
    base = File.basename(file_name)
    return base.split(".")[base.split(".").size - 1] if base.split(".").size > 1
  end

  def move_selected_file
    old_filename = params[:directories][params[:chk_files]] + "/" + params[:filenames][params[:chk_files]]
    newloc = @participant.dir_path
    newloc += "/"
    newloc += params[:faction][:move]
    begin
        FileHelper.move_file(old_filename, newloc)
        flash[:note] = "The file was successfully moved from \"/#{params[:filenames][params[:chk_files]]}\" to \"/#{params[:faction][:move]}\""
      rescue => e
        flash[:error] = "There was a problem moving the file: " + e.message
      end
  end

  def rename_selected_file
    old_filename = params[:directories][params[:chk_files]] + "/" + params[:filenames][params[:chk_files]]
    new_filename = params[:directories][params[:chk_files]] + "/" + FileHelper.sanitize_filename(params[:faction][:rename])
    begin
      if !File.exist?(new_filename)
        File.send("rename", old_filename, new_filename)
      else
        raise "A file already exists in this directory with the name \"#{params[:faction][:rename]}\""
      end
    rescue => e
      flash[:error] = "There was a problem renaming the file: " + e.message
    end
  end

  def delete_selected_files

    filename = params[:directories][params[:chk_files]] + "/" + params[:filenames][params[:chk_files]]
    FileUtils.rm_r(filename)

    #create a submission record
    assignment = Assignment.find(participant.parent_id)
    team = participant.team
    @submission_record = SubmissionRecord.new(team_id: team.id, content: full_filename, user: participant.name , assignment_id: assignment.id, operation: "Remove File")
    @submission_record.save
  end

  def copy_selected_file
    old_filename = params[:directories][params[:chk_files]] + "/" + params[:filenames][params[:chk_files]]
    new_filename = params[:directories][params[:chk_files]] + "/" + FileHelper.sanitize_filename(params[:faction][:copy])
    begin
      if File.exist?(new_filename)
        raise "A file with this name already exists. Please delete the existing file before copying."
      end

      if File.exist?(old_filename)
        FileUtils.cp_r(old_filename, new_filename)
      else
        raise "The referenced file does not exist."
      end
    rescue => e
      flash[:error] = "There was a problem copying the file: " + e.message
    end
  end

  def create_new_folder
    newloc = @participant.dir_path
    newloc += "/"
    newloc += params[:faction][:create]
    begin
      FileHelper.create_directory_from_path(newloc)
      flash[:note] = "The directory #{params[:faction][:create]} was created."
    rescue => e
      flash[:error] = e.message
    end
  end

  # def undo_link
  #  "<a href = #{url_for(:controller => :versions,:action => :revert,:id => @participant.versions.last.id)}>undo</a>"
  # end

  private
  # if one team do not hold a topic (still in waitlist), they cannot submit their work.
  def one_team_can_submit_work?
    return true if !(%w(submit_file, submit_hyperlink).include? action_name) #should work only when submit_file/hyperlink is called
    @participant = if params[:id].nil?
                     AssignmentParticipant.find(params[:hyperlinks][:participant_id])
                   else
                     AssignmentParticipant.find(params[:id])
                   end
    @topics = SignUpTopic.where(assignment_id: @participant.parent_id)
    # check one assignment has topics or not
    if (!@topics.empty? and !SignedUpTeam.topic_id(@participant.parent_id, @participant.user_id).nil?) or @topics.empty?
      return true
    else
      return false
    end
  end
end
