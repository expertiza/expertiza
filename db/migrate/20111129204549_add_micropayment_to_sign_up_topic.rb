class AddMicropaymentToSignUpTopic < ActiveRecord::Migration[4.2]
  def self.up
    add_column :sign_up_topics, :micropayment, :integer
  end

  def self.down
    remove_column :sign_up_topics, :micropayment
  end
end
