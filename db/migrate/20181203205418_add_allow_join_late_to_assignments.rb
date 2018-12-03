class AddAllowJoinLateToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :allow_join_late, :boolean
  end
end
