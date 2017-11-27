class AddTeamIdToResponseMaps < ActiveRecord::Migration
  def change
    add_column :response_maps, :team_id, :integer, limit: 4, default: 0, null: false
  end
end
