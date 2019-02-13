class CreateTeamNominations < ActiveRecord::Migration
  def change
    create_table :team_nominations do |t|
      t.integer :team_id
      t.integer :badge_id
      t.string :status
      t.integer :nominator_id

      t.timestamps null: false
    end
  end
end
