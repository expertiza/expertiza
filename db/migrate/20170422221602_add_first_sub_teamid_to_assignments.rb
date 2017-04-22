class AddFirstSubTeamidToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :first_sub_teamid, :integer, :default => 3
  end
end
