class AddTeamIdToScoreCaches < ActiveRecord::Migration
  def self.up
    add_column :score_caches, :team_id, :integer
    #add_column :score_caches, :score_bak, :float
  end
  def self.down
    remove_column :score_caches, :team_id
    #remove_column :score_caches, :score_bak
  end
end