class AddPriorityToBids < ActiveRecord::Migration
  def self.up
    add_column :bids, :priority, :integer, :default => nil
  end

  def self.down
    remove_column :bids, :priority
  end
end
