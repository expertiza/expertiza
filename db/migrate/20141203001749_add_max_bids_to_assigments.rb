class AddMaxBidsToAssigments < ActiveRecord::Migration[4.2]
  def self.up
    add_column :assignments, :max_bids, :integer
  end

  def self.down
    remove_column :assignments, :max_bids, :integer
  end
end
