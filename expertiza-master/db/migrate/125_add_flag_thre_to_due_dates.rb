class AddFlagThreToDueDates < ActiveRecord::Migration
  def self.up
    add_column :due_dates, :flag, :boolean, :default => false
    add_column :due_dates, :threshold, :integer, :default => 1   
  end

  def self.down
    remove_column :due_dates, :flag
    remove_column :due_dates, :threshold
  end
end
