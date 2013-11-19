class AddFlagBidType < ActiveRecord::Migration
  def self.up
    add_column :assignments, :bid_type, :integer, default=>0
    # bid_type=0 -- waitlist
    # bid_type=1 -- Intelligent Bid
  end

  def self.down
    remove_column :assignments, :bid_type
  end
end
