require 'zip/zip'

class StudentAssignmentController < ApplicationController
  def list
    user_id = session[:user].id
    @participants = Participant.find(:all, 
                                    :conditions => ['user_id = ?', user_id],
                                    :order => "assignment_id DESC")
  end
  
  def view_actions
    @participant = Participant.find(params[:id])
  end
  
  def submit
    @participant = Participant.find(params[:id])
    @files = Array.new
    
    @current_folder = DisplayOption.new
    @current_folder.name = "/"
    if params[:current_folder]
      @current_folder.name = StudentAssignmentHelper::sanitize_folder(params[:current_folder][:name])
    end
    
    if params['download']
      folder_name = StudentAssignmentHelper::sanitize_folder(@current_folder.name)
      file_name = StudentAssignmentHelper::sanitize_filename(params['download'])
      send_file(get_student_directory(@participant) + folder_name + "/" + file_name) 
    end
    
    if params['new_folder']
      create_new_folder
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

      if @participant.directory_num == nil or @participant.directory_num < 0
        set_student_directory_num
      end      
      
      safe_filename = StudentAssignmentHelper::sanitize_filename(file.full_original_filename)
      curr_directory = get_student_directory(@participant)+ @current_folder.name + "/"
      full_filename = curr_directory + safe_filename
      File.open(full_filename, "wb") { |f| f.write(file.read) }
      StudentAssignmentHelper::unzip_file(full_filename, curr_directory, true) if get_file_type(safe_filename) == "zip"
      
      update_resubmit_times
    end
    
    if @participant.directory_num != nil and @participant.directory_num >= 0
      get_student_folders
      get_student_files 
    end
  end

private
  def update_resubmit_times
    new_submit = ResubmissionTime.new(:resubmitted_at => Time.now.to_s)
    @participant.resubmission_times << new_submit
  end

  def create_new_folder
    new_folder = StudentAssignmentHelper::sanitize_filename(params[:new_folder])
    if !File.exist?(get_student_directory(@participant) + @current_folder.name + "/" + new_folder)
      Dir.mkdir(get_student_directory(@participant) + @current_folder.name + "/" + new_folder)
    else 
      flash[:notice] = "Directory name is already taken"
    end
  end
  
  def move_file
    for file_checked in params[:chk_files]
      old_filename = get_student_directory(@participant) + @current_folder.name + "/" + params[:filenames][file_checked[0]].to_s
      new_filename = get_student_directory(@participant) + StudentAssignmentHelper::sanitize_folder(params[:moved_file])
      file_op "move", old_filename, new_filename
      break
    end
  end
  
  def copy_file
    for file_checked in params[:chk_files]
      old_filename = get_student_directory(@participant) + @current_folder.name + "/" + params[:filenames][file_checked[0]].to_s
      new_filename = get_student_directory(@participant) + StudentAssignmentHelper::sanitize_folder(params[:copy_file])
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
      old_filename = get_student_directory(@participant) + @current_folder.name + "/" + params[:filenames][file_checked[0]].to_s
      new_filename = get_student_directory(@participant) + @current_folder.name + "/" + StudentAssignmentHelper::sanitize_filename(params[:new_filename])
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
        File.delete(get_student_directory(@participant) + @current_folder.name + "/" + filename)
      end
    end
  end

  def set_student_directory_num
    # Student has not submitted a file yet, so the directory_num
    # needs to be set before saving the file
    participants = Participant.find(:all,
                                   :conditions => "assignment_id = #{@participant.assignment_id}",
                                   :order => "directory_num DESC")
    if participants == nil or participants.size == 0
      @participant.directory_num = 0
    elsif participants != nil
      if participants[0].directory_num != nil
        @participant.directory_num = participants[0].directory_num + 1
      else
        @participant.directory_num = 0
      end
    end     
    @participant.save 
    create_student_directory
  end

  def get_student_directory(participant)
    # This assumed that the directory num has already been set
    return RAILS_ROOT + "/pg_data/" + participant.assignment.directory_path + "/" + participant.directory_num.to_s
  end

  def create_student_directory
    print "\n\n" + get_student_directory(@participant)
    Dir.mkdir(get_student_directory(@participant))
  end

  def get_student_files
    temp_files = Dir[get_student_directory(@participant) + @current_folder.name + "/*"]
    for file in temp_files
      if not File.directory?(Dir.pwd + "/" + file) then
        @files << file
      end
    end
    return @files
  end
  
  def get_student_folders
    temp_files = Dir[get_student_directory(@participant) + "/*"]
    @folders = Array.new
    @folders << "/"
    for file in temp_files
      if File.directory?(Dir.pwd + "/" + file) then
        @folders << file.gsub(get_student_directory(@participant), "")
        find_student_folders file
      end
    end
  end
  
  def find_student_folders dir
    # Find all the subfolders recursively
    temp_files = Dir[dir + "/*"]
    for file in temp_files
      if File.directory?(file) then
        @folders << file.gsub(get_student_directory(@participant), "")
        find_student_folders file
      end
    end
  end
  
  def get_file_type file_name
    base = File.basename(file_name)
	  if base.split(".").size > 1
      return base.split(".")[base.split(".").size-1]
	  end
	end
end