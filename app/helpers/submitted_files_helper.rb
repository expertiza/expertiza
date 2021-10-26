module SubmittedFilesHelper
    
  def move_selected_file
    old_filename = params[:directories][params[:chk_files]] + "/" + params[:filenames][params[:chk_files]]
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

  def rename_selected_file
    old_filename = params[:directories][params[:chk_files]] + "/" + params[:filenames][params[:chk_files]]
    new_filename = params[:directories][params[:chk_files]] + "/" + FileHelper.sanitize_filename(params[:faction][:rename])
    begin
      raise "A file already exists in this directory with the name \"#{params[:faction][:rename]}\"" if File.exist?(new_filename)
      File.send("rename", old_filename, new_filename)
    rescue StandardError => e
      flash[:error] = "There was a problem renaming the file: " + e.message
    end
  end

  def delete_selected_files
    filename = params[:directories][params[:chk_files]] + "/" + params[:filenames][params[:chk_files]]
    FileUtils.rm_r(filename)
    participant = Participant.find_by(id: params[:id])
    assignment = participant.try(:assignment)
    team = participant.try(:team)
    SubmissionRecord.create(team_id: team.try(:id),
                            content: filename,
                            user: participant.try(:name),
                            assignment_id: assignment.try(:id),
                            operation: "Remove File")
    ExpertizaLogger.info LoggerMessage.new(controller_name, @participant.name, 'The selected file has been deleted.', request)
  end

  def copy_selected_file
    old_filename = params[:directories][params[:chk_files]] + "/" + params[:filenames][params[:chk_files]]
    new_filename = params[:directories][params[:chk_files]] + "/" + FileHelper.sanitize_filename(params[:faction][:copy])
    begin
      raise "A file with this name already exists. Please delete the existing file before copying." if File.exist?(new_filename)
      raise "The referenced file does not exist." unless File.exist?(old_filename)
      FileUtils.cp_r(old_filename, new_filename)
    rescue StandardError => e
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
    rescue StandardError => e
      flash[:error] = e.message
    end
end
end
  
