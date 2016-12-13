class AddReviewerIsTeamToResponseMaps < ActiveRecord::Migration
  def up
    add_column :response_maps, :reviewer_is_team, :boolean, :default=>false
  end

  def down
    remove_column :response_maps, :reviewer_is_team
  end

end
