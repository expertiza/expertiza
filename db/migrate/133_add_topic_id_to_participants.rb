class AddTopicIdToParticipants < ActiveRecord::Migration
  def self.up
    add_column :participants, :topic_id, :integer, :null => true  
  end

  def self.down
  end
end
