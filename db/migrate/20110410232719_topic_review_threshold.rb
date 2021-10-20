class TopicReviewThreshold < ActiveRecord::Migration
  def self.up
    add_column :assignments, :review_topic_threshold, :integer, :default => 0
  end

  def self.down
    remove_column :assignments, :review_topic_threshold
  end
end
