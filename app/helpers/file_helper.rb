module FileHelper

  def self.sanitize_filename(file_name)
      just_filename = File.basename(file_name) 
      # replace all none alphanumeric, underscore or perioids with underscore
      just_filename.gsub(/[^\w\.\_]/,'_') 
  end
  
  def self.sanitize_folder(folder)
    folder.gsub("..","")
  end
  
end