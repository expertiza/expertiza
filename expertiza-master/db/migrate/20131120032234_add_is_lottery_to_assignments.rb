class AddIsLotteryToAssignments < ActiveRecord::Migration
  def self.up
    add_column :assignments, :is_lottery, :boolean
  end

  def self.down
    remove_column :assignments, :is_lottery
  end
end
