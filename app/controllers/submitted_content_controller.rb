require 'zip/zip'
require 'uri'  

class SubmittedContentController < ApplicationController
  helper :wiki
  
  def edit
    @participant = AssignmentParticipant.find(params[:id])
    @assignment = @participant.assignment
  end
  
  def view
    @participant = AssignmentParticipant.find(params[:id])
    @assignment = @participant.assignment
  end  
  
  def submit_hyperlink
    participant = AssignmentParticipant.find(params[:id]) 
    url = URI.parse(params['submission'].strip)
    begin
      Net::HTTP.start(url.host, url.port)
      participant.update_attribute('submitted_hyperlink',params['submission'].strip)
    rescue 
      flash[:error] = "The URL or URI is not valid. Reason: "+$!
    end    
    redirect_to :action => 'edit', :id => participant.id
  end    
  
  
  def submit_file
    participant = AssignmentParticipant.find(params[:id])
    file = params[:uploaded_file]
    participant.set_student_directory_num

    #send message to reviewers(s) when submission has been updated
    #ajbudlon, sept 07, 2007
    participant.assignment.email(participant.id)

    @current_folder = DisplayOption.new
    @current_folder.name = "/"
    if params[:current_folder]
      @current_folder.name = FileHelper::sanitize_folder(params[:current_folder][:name])
    end           
           
    curr_directory = participant.get_path.to_s+@current_folder.name
    

    if !File.exists? curr_directory
       FileUtils.mkdir_p(curr_directory)
    end
   
    safe_filename = file.full_original_filename.gsub(/\\/,"/")
    safe_filename = FileHelper::sanitize_filename(safe_filename) # new code to sanitize file path before upload*
    full_filename =  curr_directory + File.split(safe_filename).last.gsub(" ",'_') #safe_filename #curr_directory +
    File.open(full_filename, "wb") { |f| f.write(file.read) }
    if params['unzip']
      SubmittedContentHelper::unzip_file(full_filename, curr_directory, true) if get_file_type(safe_filename) == "zip"
    end
    participant.update_resubmit_times       
    redirect_to :action => 'edit', :id => participant.id
  end
  
  
  def folder_action
    @participant = AssignmentParticipant.find(params[:id])       
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
        send_file(folder_name+ "/" + file_name, :type => Mime::HTML.to_s, :disposition => 'inline')
      else
        if !File.directory?(folder_name + "/" + file_name)
          send_file( folder_name + "/" + file_name, :disposition => 'inline')
        else
           Net::SFTP.start("http://pg-server.csc.ncsu.edu", "*****", "****") do |sftp|
              sftp.download!(folder_name + "/" + file_name, "C:/expertiza", :recursive => true)
           end
        end
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
    newloc = @participant.get_path
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
    newloc = @participant.get_path
    newloc += "/"
    newloc += params[:faction][:create]
    begin
      FileHelper::create_directory_from_path(newloc)
      flash[:note] = "The directory #{params[:faction][:create]} was created."
    rescue
      flash[:error] = $!
    end
  end
end
