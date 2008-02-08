module StudentAssignmentHelper

  COMPLETE = "Complete"
  
  def self.find_current_stage(assignment_id)
    due_dates = DueDate.find(:all, 
                 :conditions => ["assignment_id = ?", assignment_id],
                 :order => "due_at DESC")
                 
    if due_dates != nil and due_dates.size > 0
      if Time.now > due_dates[0].due_at
        return COMPLETE
      else
        i = 0
        for due_date in due_dates
          if Time.now < due_date.due_at and
             (due_dates[i+1] == nil or Time.now > due_dates[i+1].due_at)
            return due_date
          end
          i = i + 1
        end
      end
    end
  end
  
  def self.get_current_stage(assignment_id)
    due_date = find_current_stage(assignment_id)
    if due_date == nil or due_date == COMPLETE
      return COMPLETE
    else
      return DeadlineType.find(due_date.deadline_type_id).name
    end
  end
  
  def self.get_stage_deadline(assignment_id)
    due_date = find_current_stage(assignment_id)
    if due_date == nil or due_date == COMPLETE
      return due_date
    else
      return due_date.due_at.to_s
    end
  end
  
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