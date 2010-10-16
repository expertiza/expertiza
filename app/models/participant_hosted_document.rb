# CSC/ECE-517 - Add support for hosted documents (ie Google Docs)
class ParticipantHostedDocument < ActiveRecord::Base
	belongs_to :assignment_participant

	validates_presence_of :assignment_participant_id, :url, :label, :service
end
