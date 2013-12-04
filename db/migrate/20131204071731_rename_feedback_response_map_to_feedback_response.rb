class RenameFeedbackResponseMapToFeedbackResponse < ActiveRecord::Migration
  def self.up
    rename_table :feedback_response_maps, :feedback_responses
  end

  def self.down
    rename_table :feedback_responses, :feedback_response_maps
  end
end
