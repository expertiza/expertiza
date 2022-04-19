class AddIsReviewerTeamToReviewResponseMap < ActiveRecord::Migration
  def change
    add_column :response_maps, :reviewer_is_team, :boolean
  end
end
