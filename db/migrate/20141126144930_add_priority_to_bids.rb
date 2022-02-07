class AddPriorityToBids < ActiveRecord::Migration
  def self.up
    add_column :bids, :priority, :integer
  end

  def self.down
  	remove_column :bids, :priority, :integer
  end
end
