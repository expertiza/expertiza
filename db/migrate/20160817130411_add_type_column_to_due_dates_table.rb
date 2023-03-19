class AddTypeColumnToDueDatesTable < ActiveRecord::Migration[4.2]
  def self.up
    add_column :due_dates, :type, :string, null: :false, default: 'AssignmentDueDate'
  end

  def self.down
    remove_column :due_dates, :type
  end
end
