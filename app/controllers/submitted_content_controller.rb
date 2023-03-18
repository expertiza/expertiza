class SubmittedContentController < ApplicationController
  require 'mimemagic'
  require 'mimemagic/overlay'

  include AuthorizationHelper

  before_action :ensure_current_user_is_participant, only: %i[edit show submit_hyperlink folder_action]

  # Validate whether a particular action is allowed by the current user or not based on the privileges
  # @return [Boolean] the result of validation
  def action_allowed?
    case params[:action]
    when 'edit'
      current_user_has_student_privileges? &&
        are_needed_authorizations_present?(params[:id], 'reader', 'reviewer')
    when 'submit_file', 'submit_hyperlink'
      current_user_has_student_privileges? &&
        one_team_can_submit_work?
    else
      current_user_has_student_privileges?
    end
  end

  # This function sets up the locale for the view as per the language selected by the user
  def controller_locale
    locale_for_student
  end

  # The view have already tested that @assignment.submission_allowed(topic_id) is true,
  # so @can_submit should be true
  def edit
    @assignment = @participant.assignment
    # ACS We have to check if this participant has team or not
    SignUpSheet.signup_team(@assignment.id, @participant.user_id, nil) if @participant.team.nil?
    # @can_submit is the flag indicating if the user can submit or not in current stage
    @can_submit = !params.key?(:view_only)
    @stage = @assignment.current_stage(SignedUpTeam.topic_id(@participant.parent_id, @participant.user_id))
  end

  # view is called when @assignment.submission_allowed(topic_id) is false
  # so @can_submit should be false
  def show
    @assignment = @participant.assignment
    # @can_submit is the flag indicating if the user can submit or not in current stage
    @can_submit = false
    @stage = @assignment.current_stage(SignedUpTeam.topic_id(@participant.parent_id, @participant.user_id))
    redirect_to action: 'edit', id: params[:id], view_only: true
  end

  # submit_hyperlink is called when a new hyperlink is added to an assignment.
  # This also verifies that the hyperlink doesn't already exist in the assignment submissions.
  def submit_hyperlink
    team = @participant.team
    team_hyperlinks = team.hyperlinks
    if team_hyperlinks.include?(params['submission'])
      ExpertizaLogger.error LoggerMessage.new(controller_name, @participant.name, 'You or your teammate(s) have already submitted the same hyperlink.', request)
      flash[:error] = 'You or your teammate(s) have already submitted the same hyperlink.'
    else
      begin
        team.submit_hyperlink(params['submission'])
        SubmissionRecord.create(team_id: team.id,
                                content: params['submission'],
                                user: @participant.name,
                                assignment_id: @participant.assignment.id,
                                operation: 'Submit Hyperlink')
      rescue StandardError
        ExpertizaLogger.error LoggerMessage.new(controller_name, @participant.name, "The URL or URI is invalid. Reason: #{$ERROR_INFO}", request)
        flash[:error] = "The URL or URI is invalid. Reason: #{$ERROR_INFO}"
      end
      @participant.mail_assigned_reviewers
      ExpertizaLogger.info LoggerMessage.new(controller_name, @participant.name, 'The link has been successfully submitted.', request)
      undo_link('The link has been successfully submitted.')
    end
    redirect_to action: 'edit', id: @participant.id
  end

  # remove_hypelink is called when an existing hyperlink is removed from an assignment
  def remove_hyperlink
    @participant = AssignmentParticipant.find(params[:hyperlinks][:participant_id])
    return unless current_user_id?(@participant.user_id)

    team = @participant.team
    hyperlink_to_delete = team.hyperlinks[params['chk_links'].to_i]
    team.remove_hyperlink(hyperlink_to_delete)
    ExpertizaLogger.info LoggerMessage.new(controller_name, @participant.name, 'The link has been successfully removed.', request)
    undo_link('The link has been successfully removed.')
    # determine if the user should be redirected to "edit" or  "view" based on the current deadline
    topic_id = SignedUpTeam.topic_id(@participant.parent_id, @participant.user_id)
    assignment = Assignment.find(@participant.parent_id)
    SubmissionRecord.create(team_id: team.id,
                            content: hyperlink_to_delete,
                            user: @participant.name,
                            assignment_id: assignment.id,
                            operation: 'Remove Hyperlink')
    action = (assignment.submission_allowed(topic_id) ? 'edit' : 'show')
    redirect_to action: action, id: @participant.id
  end

  # submit_file is called when a new file is uploaded to an assignment.
  # This validates the file with respect to file type and file size and if it is valid
  # it uploads the file and adds it to the assignemt.
  def submit_file
    participant = AssignmentParticipant.find(params[:id])
    unless current_user_id?(participant.user_id)
      flash[:error] = "Authentication Error"
      redirect_to action: 'edit', id: participant.id
      return
    end

    file = params[:uploaded_file]
    file_size_limit = 5
    file_content = file.read

    if (!validate_file_size_type(file, file_size_limit, file_content))
      redirect_to action: 'edit', id: participant.id
      return
    end

    participant.team.set_student_directory_num
    curr_directory = get_curr_directory(participant)
    FileUtils.mkdir_p(curr_directory) unless File.exist? curr_directory
    sanitized_file_path = get_sanitized_file_path(file, curr_directory)
    File.open(sanitized_file_path, 'wb') { |f| f.write(file_content) }
    if params['unzip']
      SubmittedContentHelper.unzip_file(sanitized_file_path, curr_directory, true) if file_type(safe_filename) == 'zip'
    end
    assignment = Assignment.find(participant.parent_id)
    SubmissionRecord.create(team_id: participant.team.id,
                            content: sanitized_file_path,
                            user: participant.name,
                            assignment_id: assignment.id,
                            operation: "Submit File")
    ExpertizaLogger.info LoggerMessage.new(controller_name, participant.name, 'The file has been submitted.', request)

    # Notify all reviewers assigned to this reviewee
    participant.mail_assigned_reviewers

    if params[:origin] == 'review'
      redirect_back fallback_location: root_path
    else
      redirect_to action: 'edit', id: participant.id
    end
  end

  # Check file content size and file type
  # @param file [Object] uploaded file
  # @param file_size_limit [Integer] maximum size(MB)
  # @param file_content [Object] content of the uploaded file
  # @return [Boolean] the result of validation
  def validate_file_size_type(file, file_size_limit, file_content)
    # check file size
    unless check_content_size(file, file_size_limit)
      flash[:error] = "File size must smaller than #{file_size_limit}MB"
      return false
    end

    # check file type
    unless check_content_type_integrity(file_content)
      flash[:error] = 'File type error'
      return false
    end

    true
  end

  # Sanitize and return the file name
  # @param file [Object] uploaded file
  # @param curr_directory [String] directory path for the file
  # @return sanitized_file_path [String] sanitized file path
  def get_sanitized_file_path(file, curr_directory)
    safe_filename = file.original_filename.tr('\\', '/')
    safe_filename = FileHelper.sanitize_filename(safe_filename) # new code to sanitize file path before upload*
    sanitized_file_path = curr_directory + File.split(safe_filename).last.tr(' ', '_') # safe_filename #curr_directory
    sanitized_file_path
  end

  # Get current directory path
  # @param participant [Object] participant object
  # @return curr_directory [String] current directory path for the participant
  def get_curr_directory(participant)
    current_folder = DisplayOption.new
    current_folder.name = '/'
    current_folder.name = FileHelper.sanitize_folder(params[:current_folder][:name]) if params[:current_folder]
    curr_directory = if params[:origin] == 'review'
                       participant.review_file_path(params[:response_map_id]).to_s + current_folder.name
                     else
                       participant.team.path.to_s + current_folder.name
                     end
    curr_directory
  end

  # folder_action is called by the view when a file is deleted from the list of uploaded files.
  def folder_action
    @current_folder = DisplayOption.new
    @current_folder.name = '/'
    @current_folder.name = FileHelper.sanitize_folder(params[:current_folder][:name]) if params[:current_folder]
    if params[:faction][:delete]
      delete_selected_files
    end
    redirect_to action: 'edit', id: @participant.id
  end

  # download is called when a user opens an existing uploaded file
  def download
    folder_name = params[:current_folder][:name]
    file_name = params[:download]
    raise 'Folder_name is nil.' if folder_name.nil?
    raise 'File_name is nil.' if file_name.nil?
    raise 'Cannot send a whole folder.' if File.directory?(folder_name + '/' + file_name)
    raise 'File does not exist.' unless File.exist?(folder_name + '/' + file_name)

    send_file(folder_name + '/' + file_name, disposition: 'inline')
  rescue StandardError => e
    flash[:error] = e.message
  end

  private

  # Verify the integrity of uploaded files.
  # @param file_content [Object] the content of uploaded file
  # @return [Boolean] the result of verification
  def check_content_type_integrity(file_content)
    limited_types = %w[application/pdf image/png image/jpeg application/zip application/x-tar application/x-7z-compressed application/vnd.oasis.opendocument.text application/vnd.openxmlformats-officedocument.wordprocessingml.document]
    mime = MimeMagic.by_magic(file_content)
    limited_types.include? mime.to_s
  end

  # Verify the size of uploaded file is under specific value.
  # @param file [Object] uploaded file
  # @param size [Integer] maximum size(MB)
  # @return [Boolean] the result of verification
  def check_content_size(file, size)
    file.size <= size * 1024 * 1024
  end

  # file_type returns the type of file from the file name
  # @param file_name [String] file name
  # @return [String] type of the uploaded file
  def file_type(file_name)
    base = File.basename(file_name)
    base.split('.')[base.split('.').size - 1] if base.split('.').size > 1
  end

  # This function is responsible for deleting the uploaded files from the assignment
  def delete_selected_files
    filename = params[:directories][params[:chk_files]] + '/' + params[:filenames][params[:chk_files]]
    FileUtils.rm_r(filename)
    participant = Participant.find_by(id: params[:id])
    assignment = participant.try(:assignment)
    team = participant.try(:team)
    SubmissionRecord.create(team_id: team.try(:id),
                            content: filename,
                            user: participant.try(:name),
                            assignment_id: assignment.try(:id),
                            operation: 'Remove File')
    ExpertizaLogger.info LoggerMessage.new(controller_name, @participant.name, 'The selected file has been deleted.', request)
  end

  # if one team do not hold a topic (still in waitlist), they cannot submit their work.
  def one_team_can_submit_work?
    @participant = if params[:id].nil?
                     AssignmentParticipant.find(params[:hyperlinks][:participant_id])
                   else
                     AssignmentParticipant.find(params[:id])
                   end
    @topics = SignUpTopic.where(assignment_id: @participant.parent_id)
    # check one assignment has topics or not
    (!@topics.empty? && !SignedUpTeam.topic_id(@participant.parent_id, @participant.user_id).nil?) || @topics.empty?
  end

  # This check ensures that the current user accessing the assignment is a participant for that particular assignment.
  def ensure_current_user_is_participant
    @participant = AssignmentParticipant.find(params[:id])
    return unless current_user_id?(@participant.user_id)
  end
end
