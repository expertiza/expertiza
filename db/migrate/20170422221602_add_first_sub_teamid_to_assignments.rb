class AddFirstSubTeamidToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :first_sub_teamid, :integer, :default => -1
  end
end
