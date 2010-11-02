class AddTopicDescriptionToSignUpTopics < ActiveRecord::Migration
# OSS project_Team1 (rsjohns3) CSC517 Fall 2010
# This migration adds topic_description column to sign_up_topics table
# to allow topic description from suggestions to be preserved when
# suggestions are approved and turned into official signup topics
#
  def self.up
    add_column :sign_up_topics, :topic_description, :string
  end

  def self.down
    remove_column :sign_up_topics, :topic_description
  end
end
