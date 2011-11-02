class AddMaxTopicCountToAssignment < ActiveRecord::Migration
  def self.up
    add_column :assignments, :max_topic_count, :int
  end

  def self.down
    remove_column :assignments, :max_topic_count
  end
end
