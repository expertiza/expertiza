class AddCanChooseTopicToReview < ActiveRecord::Migration
  def self.up
    add_column :assignments, :can_choose_topic_to_review, :boolean, default: true
  end

  def self.down
    remove_colmun :assignments, :can_choose_topic_to_review
  end
end
