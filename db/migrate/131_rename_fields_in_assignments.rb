class RenameFieldsInAssignments < ActiveRecord::Migration
  def self.up
    begin
      remove_column :assignments, :start_date
    rescue StandardError
    end
    add_column :assignments, :days_between_submissions, :integer
  end

  def self.down; end
end
