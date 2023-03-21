class AddPriorityToBids < ActiveRecord::Migration[4.2]
  def self.up
    add_column :bids, :priority, :integer
  end

  def self.down
    remove_column :bids, :priority, :integer
  end
end
