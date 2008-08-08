module StudentAssignmentHelper

  COMPLETE = "Complete"
  
  def self.get_grade(participant_id)
    return 0
  end
  
  def self.date_plus_days(days)
    t = Time.now
    t = t + days * (60*60*24)
    return t.strftime("%Y-%m-%d")
  end
  
  # Installing RubyZip 
  # run the command,  gem install rubyzip
  # restart the server
  def self.unzip_file(file_name, unzip_dir, should_delete)
   #begin
      Zip::ZipFile::open(file_name) {
        |zf| zf.each { |e|
          fpath = File.join(unzip_dir, e.name)
          FileUtils.mkdir_p(File.dirname(fpath))
          zf.extract(e, fpath) } }
    
          if should_delete
            # The zip file is no longer needed, so delete it
            File.delete(file_name)
          end
    #rescue
    #end
  end
  
  def get_feedback_text(review_id)
    return params['author_6']
  end
  
end