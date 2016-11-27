class AddNewMembersToTeams < ActiveRecord::Migration
  def self.up
    add_column :teams, :new_members, :boolean, default: false
  end

  def self.down
    remove_column :teams, :new_members
  end
end