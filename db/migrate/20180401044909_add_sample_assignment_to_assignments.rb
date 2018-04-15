class AddSampleAssignmentToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :sample_assignment_id, :integer, index: true
    add_foreign_key :assignments, :assignments, column: :sample_assignment_id
  end
end
