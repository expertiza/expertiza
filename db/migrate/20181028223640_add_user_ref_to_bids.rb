class AddUserRefToBids < ActiveRecord::Migration
  def change
    add_column :bids, :user_id, :int
  end
end
