class CreateRevisionPlanTeamMaps < ActiveRecord::Migration
  def change
    create_table :revision_plan_team_maps do |t|
      t.references :team, index: true, foreign_key: true
      t.references :questionnaire, index: true, foreign_key: true
      t.integer :used_in_round

      t.timestamps null: false
    end
  end
end
