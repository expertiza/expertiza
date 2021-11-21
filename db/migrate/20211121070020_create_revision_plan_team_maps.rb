class CreateRevisionPlanTeamMaps < ActiveRecord::Migration
  def change
    create_table :revision_plan_team_maps do |t|
      t.string :revision_plan_team_map_id
      t.integer :team_id
      t.boolean :used_in_round

      t.timestamps null: false
    end
    add_index :revision_plan_team_maps, :revision_plan_team_map_id, unique: true
  end
end
