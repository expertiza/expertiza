class RenameTeamReviewResponseMapToTeamReviewResponse < ActiveRecord::Migration
  def self.up
    rename_table :team_review_response_maps, :team_review_responses
  end

  def self.down
    rename_table :team_review_responses, :team_review_response_maps
  end
end
