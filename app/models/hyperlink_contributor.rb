#The model records all participants who have submitted atleast one hyperlink at any point of time
#Delete in this table will happen when the participant record gets deleted
#Or if at any point of time participant's YAML becomes zero size
require 'track_hyperlink'

class HyperlinkContributor < ActiveRecord::Base
  belongs_to :participant

  def self.check_for_updates
    self.find_each do |contributor|
	  hyperlinks_yaml = contributor.participant.submitted_hyperlinks
	  hyperlinks = hyperlinks_yaml.blank? ? [] : YAML::load(hyperlinks_yaml)
	  hyperlinks.each do |hyperlink|
	    #track here    
		begin
		  new_ts = TrackHyperlink.new(hyperlink).retrieve_modify_timestamp()
		  last_update_ev = SubmissionHistory.where("participant_id = ? and artifact_name = ? and event = ?", 
		  										contributor.participant_id, hyperlink,
		  										SubmissionHistory.events[:EVENT_HYPERLINK_UPDATED])
		  										.select(:event_time)
		  										.order(:event_time)
		  										.first
		  old_ts = last_update_ev.nil? ? "0" : last_update_ev.event_time
		  if !new_ts.nil? && new_ts > old_ts
		    SubmissionHistory.create_new_hyperlink_update_event(contributor.participant_id, hyperlink, new_ts)
		  end
		rescue
		  #do nothing for now and carry on with other entries, might be a temp connection error with server
		  puts "#{Time.now} Exception occured #{$!}"
		end
	  end
	  puts "#{Time.now} : #{hyperlinks.length} links processed for participant #{contributor.participant_id}"
	end
  end

end
