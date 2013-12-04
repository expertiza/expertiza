class RenameParticipantReviewResponseMapToParticipantReviewResponse < ActiveRecord::Migration
  def self.up
    rename_table :participant_review_response_maps, :participant_review_responses
  end

  def self.down
    rename_table :participant_review_responses, :participant_review_response_maps
  end
end
