class RenameFieldsInAssignments < ActiveRecord::Migration[4.2]
  def self.up
    begin
      remove_column :assignments, :start_date
    rescue
    end
    add_column :assignments, :days_between_submissions, :integer
  end

  def self.down
  end
end