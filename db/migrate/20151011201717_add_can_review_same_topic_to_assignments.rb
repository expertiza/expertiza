class AddCanReviewSameTopicToAssignments < ActiveRecord::Migration
  def self.up
    add_column :assignments, :can_review_same_topic, :boolean, default: true
  end

  def self.down
    remove_colmun :assignments, :can_review_same_topic
  end
end
