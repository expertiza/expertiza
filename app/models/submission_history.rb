#Stores submission history for every participant as a collection of events with their timestamps
class SubmissionHistory < ActiveRecord::Base
  belongs_to :participant

  #event types
  @@events = 
  {
  :EVENT_NEW_FILE_SUBMITTED => "new file submitted",
  :EVENT_FILE_RESUBMITTED => "file re-submitted",
  :EVENT_FILE_DELETED => "file deleted",
  :EVENT_HYPERLINK_SUBMITTED => "hyperlink submitted",
  :EVENT_HYPERLINK_UPDATED => "hyperlink content updated",
  :EVENT_HYPERLINK_DELETED => "hyperlink deleted"
  }

  #artifact types
  ARTIFACT_TYPE_FILE = "file"
  ARTIFACT_TYPE_HYPERLINK = "hyperlink"
  
  cattr_reader :events 

  def self.create_file_submission_event(participant_id, file_name)
    ev = SubmissionHistory.create(participant_id:participant_id, 
								  artifact_name:file_name, 
								  artifact_type:ARTIFACT_TYPE_FILE, 
								  event:self.events[:EVENT_NEW_FILE_SUBMITTED], 
								  event_time:Time.now)
  end

  def self.create_hyperlink_submission_event(participant_id, hyperlink)
    ev = SubmissionHistory.create(participant_id:participant_id, 
								  artifact_name:hyperlink, 
								  artifact_type:ARTIFACT_TYPE_HYPERLINK, 
								  event:self.events[:EVENT_HYPERLINK_SUBMITTED], 
								  event_time:Time.now)
  end

end
