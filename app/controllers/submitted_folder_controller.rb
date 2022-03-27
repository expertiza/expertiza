class SubmittedFolderController < ApplicationController
  # Function to redirect user to appropriate file editing,creation options and new folder options.
  def perform_folder_action
    @participant = AssignmentParticipant.find(params[:id])
    return unless current_user_id?(@participant.user_id)

    @current_folder = DisplayOption.new
    @current_folder.name = "/"
    @current_folder.name = FileHelper.sanitize_folder(params[:current_folder][:name]) if params[:current_folder]
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

  # Raises error if there are issues with downloading of current selected folder and file in it
  def download
    begin
      folder_name = params['current_folder']['name']
      file_name = params['download']
      raise "Folder_name is nil." if folder_name.nil?
      raise "File_name is nil." if file_name.nil?
      raise "Cannot send a whole folder." if File.directory?(folder_name + "/" + file_name)
      raise "File does not exist." unless File.exist?(folder_name + "/" + file_name)

      send_file(folder_name + "/" + file_name, disposition: 'inline')
    rescue StandardError => e
      flash[:error] = e.message
    end
  end

  def controller_locale
    locale_for_student
  end

  # Moves file from current location/directory to specified directory/location and raises error if any problem occurs
  def move_selected_file
    # Fetch old file name
    old_filename = params[:directories][params[:chk_files]] + "/" + params[:filenames][params[:chk_files]]
    # New location path
    newloc = @participant.dir_path
    newloc += "/"
    newloc += params[:faction][:move]
    begin
      FileHelper.move_file(old_filename, newloc)
      flash[:note] = "The file was successfully moved from \"/#{params[:filenames][params[:chk_files]]}\" to \"/#{params[:faction][:move]}\""
    rescue StandardError => e
      flash[:error] = "There was a problem moving the file: " + e.message
    end
  end

  # To rename a selected file, checks any discrepancies in new file name, if new filename is same as some existing filename in current directory
  # error is flashed.
  def rename_selected_file
    # Fetch the old file name
    old_filename = params[:directories][params[:chk_files]] + "/" + params[:filenames][params[:chk_files]]
    new_filename = params[:directories][params[:chk_files]] + "/" + FileHelper.sanitize_filename(params[:faction][:rename])
    # Check if the file with already existing name is present in the directory and if so raise the error else rename the file
    begin
      raise "A file already exists in this directory with the name \"#{params[:faction][:rename]}\"" if File.exist?(new_filename)

      File.send("rename", old_filename, new_filename)
    rescue StandardError => e
      flash[:error] = "There was a problem renaming the file: " + e.message
    end
  end

  # Function to delete selected file
  def delete_selected_files
    # Fetch the file name
    filename = params[:directories][params[:chk_files]] + "/" + params[:filenames][params[:chk_files]]
    # Remove the file using FileUtils
    FileUtils.rm_r(filename)
    # Fetch username, assignment and team to remove the file. 
    participant = Participant.find_by(id: params[:id])
    assignment = participant.try(:assignment)
    team = participant.try(:team)
    # Create a new submission record of deletion
    SubmissionRecord.create(team_id: team.try(:id),
                            content: filename,
                            user: participant.try(:name),
                            assignment_id: assignment.try(:id),
                            operation: "Remove File")
    ExpertizaLogger.info LoggerMessage.new(controller_name, @participant.name, 'The selected file has been deleted.', request)
  end

  # Function to copy selected file
  def copy_selected_file
    # Fetch old file name
    old_filename = params[:directories][params[:chk_files]] + "/" + params[:filenames][params[:chk_files]]
    # Create new file name
    new_filename = params[:directories][params[:chk_files]] + "/" + FileHelper.sanitize_filename(params[:faction][:copy])
    begin
      raise "A file with this name already exists. Please delete the existing file before copying." if File.exist?(new_filename)
      raise "The referenced file does not exist." unless File.exist?(old_filename)

      FileUtils.cp_r(old_filename, new_filename)
    rescue StandardError => e
      flash[:error] = "There was a problem copying the file: " + e.message
    end
  end

  # Function to create new folder
  def create_new_folder
    newloc = @participant.dir_path
    newloc += "/"
    newloc += params[:faction][:create]
    begin
      FileHelper.create_directory_from_path(newloc)
      flash[:note] = "The directory #{params[:faction][:create]} was created."
    rescue StandardError => e
      flash[:error] = e.message
    end
  end
end
