class AddCanReviewSameTopicToAssignments < ActiveRecord::Migration[4.2]
  def self.up
    add_column :assignments, :can_review_same_topic, :boolean, default: true
  end

  def self.down
    remove_colmun :assignments, :can_review_same_topic
  end
end
