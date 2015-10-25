class RemoveTopicFromParticipants < ActiveRecord::Migration
  def self.up
    remove_column :participants, :topic
  end

  def self.down
    add_column :participants, :topic, :string
  end
end
