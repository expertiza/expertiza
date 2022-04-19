class AddColumn2ToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :is_duty_based_assignment, :boolean
  end
end
