class AddShowTeammateScoreToAssignments < ActiveRecord::Migration
  def self.up
    add_column :assignments, :show_teammate_score, :boolean, default: false
  end

  def self.down
    remove_column :assignments, :show_teammate_score
  end
end
