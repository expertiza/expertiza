class RenameReviewResponseMapToReviewResponse < ActiveRecord::Migration
  def self.up
    rename_table :review_response_maps, :review_responses
  end

  def self.down
    rename_table :review_responses, :review_response_maps
  end
end
