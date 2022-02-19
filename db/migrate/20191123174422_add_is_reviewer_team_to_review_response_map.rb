class AddIsReviewerTeamToReviewResponseMap < ActiveRecord::Migration[4.2]
  def change
    add_column :response_maps, :reviewer_is_team, :boolean
  end
end
