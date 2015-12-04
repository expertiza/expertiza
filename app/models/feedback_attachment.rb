class FeedbackAttachment < ActiveRecord::Base
  validate :attachment_type_validation
  def attachment_type_validation
   #if not ["image/png", "image/jpg", "application/pdf"].include? self.content_type
    if not FeedbackAttachmentSetting.pluck(:file_type).include? self.content_type
    errors.add(:content_type, "This type of file cannot be uploaded schmuk!")
    end

  end
  def uploaded_file=(incoming_file)
    self.filename = incoming_file.original_filename
    self.content_type = incoming_file.content_type
    self.data = incoming_file.read

  end

  def filename=(new_filename)
    write_attribute("filename", sanitize_filename(new_filename))
  end

  private
  def sanitize_filename(filename)
    #get only the filename, not the whole path (from IE)
    just_filename = File.basename(filename)
    #replace all non-alphanumeric, underscore or periods with underscores
    just_filename.gsub(/[^\w\.\-]/, '_')
  end
end