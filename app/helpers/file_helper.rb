module FileHelper

  def self.sanitize_filename(file_name)
      just_filename = File.basename(file_name) 
      FileHelper.clean_path(just_filename) 
  end
  
  # replace invalid characters with underscore
  #    valid: period
  #           underscore
  #           forward slash
  #           alphanumeric characters
  def self.clean_path(file_name)
    file_name.gsub(/[^\w\.\_\/]/,'_') 
  end
  
  
  def self.sanitize_folder(folder)
    folder.gsub("..","")
  end
  
  def self.delete_directory(in_object)
    begin
      entries = Dir.entries(in_object.get_path)    
      if entries and entries.size == 2
         FileUtils.remove_dir(in_object.get_path)          
     end 
    rescue PathError
      # No action required 
    rescue
      raise "An error was encountered while deleting the directory: "+$!
    end      
  end 
  
  def self.create_directory(in_object)     
    begin
      if !File.exists? in_object.get_path
        FileUtils.mkdir_p(in_object.get_path)
      end
    rescue PathError
      puts $!
    rescue
      puts $!
      raise "An error was encountered while creating this directory: "+$!
    end   
  end  
  
  def self.create_directory_from_path(path)     
    begin
      if !File.exists? path
        FileUtils.mkdir_p(path)
      end
    rescue PathError
      puts $!
    rescue
      puts $!
      raise "An error was encountered while creating this directory: "+$!
    end   
  end   
end