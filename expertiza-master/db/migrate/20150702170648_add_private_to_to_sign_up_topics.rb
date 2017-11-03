class AddPrivateToToSignUpTopics < ActiveRecord::Migration
  def self.up
    add_column "sign_up_topics","private_to",:integer, :default => nil
  end

  def self.down
    remove_column "sign_up_topics","private_to"
  end
end

