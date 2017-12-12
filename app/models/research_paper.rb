class ResearchPaper < ActiveRecord::Base
  mount_uploader :attachment, AttachmentUploader
  #belongs_to :writer, class_name: 'User', foreign_key: 'writer_id'
end
