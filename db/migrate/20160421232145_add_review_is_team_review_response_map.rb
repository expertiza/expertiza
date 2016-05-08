class AddReviewIsTeamReviewResponseMap < ActiveRecord::Migration
  def change
  	add_column :response_maps, :reviewer_is_team, :boolean, default: false
  end
end
