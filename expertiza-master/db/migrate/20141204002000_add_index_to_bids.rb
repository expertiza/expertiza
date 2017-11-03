class AddIndexToBids < ActiveRecord::Migration
   def self.up
      add_index :bids, :team_id
      add_index :bids, :topic_id
   end

   def self.down
   	remove_index :bids, :topic_id
	remove_index :bids, :team_id
   end
end
