class RemoveTopicIdFromParticipants < ActiveRecord::Migration
  def self.up
  	remove_column :participants, :topic_id
  end

  def self.down
  	add_column :participants, :topic_id
  end
end
