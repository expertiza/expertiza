class UpdateMicropaymentToSignUpTopic < ActiveRecord::Migration
  def self.up

   change_column :sign_up_topics, :micropayment, :integer, :default => 0
   SignUpTopic.update_all ["micropayment", 0]
  end

  def self.down
  end
end
