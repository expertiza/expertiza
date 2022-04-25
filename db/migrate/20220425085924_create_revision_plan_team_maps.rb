class CreateRevisionPlanTeamMaps < ActiveRecord::Migration[5.1]
  def change
    create_table :revision_plan_team_maps do |t|
      t.references :team, index: true, foreign_key: true, type: :integer
      t.references :questionnaire, index: true, foreign_key: true, type: :integer
      t.integer :used_in_round
      t.timestamps null: false
    end
  end
end
