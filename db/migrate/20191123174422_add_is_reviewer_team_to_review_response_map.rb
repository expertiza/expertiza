class AddIsReviewerTeamToReviewResponseMap < ActiveRecord::Migration[4.2]
  def change
    add_column :response_maps, :team_reviewing_enabled, :boolean, default: false
  end
end
