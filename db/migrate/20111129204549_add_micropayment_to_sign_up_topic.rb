class AddMicropaymentToSignUpTopic < ActiveRecord::Migration
  def self.up
    add_column :sign_up_topics, :micropayment, :integer
  end

  def self.down
    remove_column :sign_up_topics, :micropayment
  end
end
