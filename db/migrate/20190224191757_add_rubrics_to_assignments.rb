class AddRubricsToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :can_modify_rubric, :boolean
  end
end
