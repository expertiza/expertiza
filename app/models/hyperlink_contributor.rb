#The model records all participants who have submitted atleast one hyperlink at any point of time
#Delete in this table will happen when the participant record gets deleted
#Or if at any point of time participant's YAML becomes zero size
class HyperlinkContributor < ActiveRecord::Base
  belongs_to :participant

  def self.check_for_updates
    self.find_each do |contributor|
	  hyperlinks_yaml = contributor.participant.submitted_hyperlinks
	  hyperlinks = hyperlinks_yaml.blank? ? [] : YAML::load(hyperlinks_yaml)
	  hyperlinks.each do |hyperlink|
	    #track here    
		new_ts = TrackHyperLink.retrieve_modify_timestamp(hyperlink)
		last_update_ev = submission_history.where("participant_id = ? and artifact_name = ? and event_type = ", 
												contributor.participant_id, hyperlink,
												SubmissionHistory.events[EVENT_HYPERLINK_UPDATED])
												.select(:event_timestamp)
												.order(:event_timestamp)
												.first
		old_ts = last_update_ev.nil? ? 0 : last_update_ev.event_timestamp
		if new_ts > old_ts
		  SubmissionHistory.create_new_hyperlink_update_event(contributor.participant_id, hyperlink, new_ts)
		end
	  end
	end
  end

end
