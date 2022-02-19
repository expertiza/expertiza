class ChangeAssignmentIdInDueDatesTableToParentId < ActiveRecord::Migration[4.2]
  def self.up
    remove_foreign_key :due_dates, column: :assignment_id
    rename_column :due_dates, :assignment_id, :parent_id
  end

  def self.down
    rename_column :due_dates, :parent_id, :assignment_id
    add_foreign_key :due_dates, :assignment
  end
end
