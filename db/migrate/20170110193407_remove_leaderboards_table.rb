class RemoveLeaderboardsTable < ActiveRecord::Migration[4.2]
  def self.up
    drop_table :leaderboards
  end

  def self.down
    create_table :leaderboards, force: true do |t|
      t.integer :questionnaire_type_id
      t.text :name
      t.text :qtype
    end
  end
end
