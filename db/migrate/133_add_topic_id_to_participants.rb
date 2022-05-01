class AddTopicIdToParticipants < ActiveRecord::Migration[4.2]
  def self.up
    add_column :participants, :topic_id, :integer, null: true
  end

  def self.down; end
end
