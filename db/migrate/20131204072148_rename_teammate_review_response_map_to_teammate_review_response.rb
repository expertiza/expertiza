class RenameTeammateReviewResponseMapToTeammateReviewResponse < ActiveRecord::Migration
  def self.up
    rename_table :teammate_review_response_maps, :teammate_review_responses
  end

  def self.down
    rename_table :teammate_review_responses, :teammate_review_response_maps
  end
end
