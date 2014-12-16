class AddIndexToBids < ActiveRecord::Migration
   def change
      add_index :bids, :team_id
      add_index :bids, :topic_id
   end
end
