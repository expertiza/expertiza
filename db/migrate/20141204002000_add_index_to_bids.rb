class AddIndexToBids < ActiveRecord::Migration[4.2]
   def self.up
      add_index :bids, :team_id
      add_index :bids, :topic_id
   end

  def self.down
    remove_index :bids, :topic_id
    remove_index :bids, :team_id
  end
end
