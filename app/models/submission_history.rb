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
  :EVENT_HYPERLINK_DELETED => "hyperlink deleted",
  :EVENT_REVIEW_SUBMITTED => "review submitted",
  :EVENT_REVIEW_RESUBMITTED => "next round review submitted",
  :EVENT_FEEDBACK_SUBMITTED => "feedback submitted",
  :EVENT_FEEDBACK_RECEIVED => "feedback received"
  }

  #artifact types
  ARTIFACT_TYPE_FILE = "file"
  ARTIFACT_TYPE_HYPERLINK = "hyperlink"
  ARTIFACT_TYPE_REVIEW = "review"
  ARTIFACT_TYPE_FEEDBACK = "feedback"
  
  cattr_reader :events 

  def self.create_file_submission_event(participant_id, file_name)
    ev = SubmissionHistory.create(participant_id:participant_id, 
								  artifact_name:file_name, 
								  artifact_type:ARTIFACT_TYPE_FILE, 
								  event:self.events[:EVENT_NEW_FILE_SUBMITTED], 
								  event_time:Time.now)
  end

  def self.create_file_resubmission_event(participant_id, file_name)
    ev = SubmissionHistory.create(participant_id:participant_id, 
								  artifact_name:file_name, 
								  artifact_type:ARTIFACT_TYPE_FILE, 
								  event:self.events[:EVENT_FILE_RESUBMITTED], 
								  event_time:Time.now)
  end

  def self.create_hyperlink_submission_event(participant_id, hyperlink)
    ev = SubmissionHistory.create(participant_id:participant_id,
                                  artifact_name:hyperlink,
                                  artifact_type:ARTIFACT_TYPE_HYPERLINK,
                                  event:self.events[:EVENT_HYPERLINK_SUBMITTED],
                                  event_time:Time.now)
  end

  def self.create_new_hyperlink_update_event(participant_id, hyperlink, event_ts)
    ev = SubmissionHistory.create(participant_id:participant_id,
                                  artifact_name:hyperlink,
                                  artifact_type:ARTIFACT_TYPE_HYPERLINK,
                                  event:self.events[:EVENT_HYPERLINK_UPDATED],
                                  event_time:event_ts)
  end

  def self.create_review_submission_event(participant_id, map_id)
    artifact_name = "Review by #{map_id}"
    ev = SubmissionHistory.create(participant_id:participant_id,
                                  artifact_name:artifact_name,
                                  artifact_type:ARTIFACT_TYPE_REVIEW,
                                  event:self.events[:EVENT_REVIEW_SUBMITTED],
                                  event_time:Time.now)
  end

  def self.create_review_resubmission_event(participant_id, map_id)
    artifact_name = "Review by #{map_id}"
    ev = SubmissionHistory.create(participant_id:participant_id,
                                  artifact_name:artifact_name,
                                  artifact_type:ARTIFACT_TYPE_REVIEW,
                                  event:self.events[:EVENT_REVIEW_RESUBMITTED],
                                  event_time:Time.now)
  end

  def self.create_feedback_submission_event(reviewer_participant_id, reviewee_participant_id )
    artifact_name1 = "Feedback submitted"
    ev = SubmissionHistory.create(participant_id:reviewer_participant_id,
                                  artifact_name:artifact_name1,
                                  artifact_type:ARTIFACT_TYPE_FEEDBACK,
                                  event:self.events[:EVENT_FEEDBACK_SUBMITTED],
                                  event_time:Time.now)
    artifact_name2 = "Feedback received"
    ev = SubmissionHistory.create(participant_id:reviewee_participant_id,
                                  artifact_name:artifact_name2,
                                  artifact_type:ARTIFACT_TYPE_FEEDBACK,
                                  event:self.events[:EVENT_FEEDBACK_RECEIVED],
                                  event_time:Time.now)
  end
end
