class CreateRevisionPlanTeamMaps < ActiveRecord::Migration[5.1]
  def change
    create_table :revision_plan_team_maps do |t|
      t.references :team, foreign_key: true, type: :integer
      t.references :questionnaire, foreign_key: true, type: :integer
      t.integer :used_in_round
      t.timestamps null: false
    end
  end
end
