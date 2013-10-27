class UpdateAssignmentsForInvitations < ActiveRecord::Migration
  def self.up   
    begin
      add_column :assignments, :team_count, :integer, :null => false, :default => 0
    rescue
    end
  
    begin
      remove_column :assignments, :max_team_count
    rescue
    end  
  end

  def self.down
    remove_column :assignments, :team_count
    add_column :assignments, :max_team_count, :boolean
  end
end
