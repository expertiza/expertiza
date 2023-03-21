class DueDateRounds < ActiveRecord::Migration[4.2]
  def self.up
    add_column 'due_dates', 'round', :integer
  end

  def self.down
    remove_column 'due_dates', 'round'
  end
end
