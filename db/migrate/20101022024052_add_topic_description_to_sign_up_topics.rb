class AddTopicDescriptionToSignUpTopics < ActiveRecord::Migration
  def self.up
    add_column :sign_up_topics, :topic_description, :string
  end

  def self.down
    remove_column :sign_up_topics, :topic_description
  end
end
