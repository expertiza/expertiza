class AddPriorityToBids < ActiveRecord::Migration
  def change
    add_column :bids, :priority, :integer
  end
end
