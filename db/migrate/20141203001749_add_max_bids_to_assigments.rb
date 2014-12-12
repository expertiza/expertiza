class AddMaxBidsToAssigments < ActiveRecord::Migration
  def change
    add_column :assignments, :max_bids, :integer
  end
end
