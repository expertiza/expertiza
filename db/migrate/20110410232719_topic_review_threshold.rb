class TopicReviewThreshold < ActiveRecord::Migration
  def self.up
    add_column :assignments, :review_topic_threshold, :integer
  end

  def self.down
    remove_column :assignments, :review_topic_threshold
  end
end
