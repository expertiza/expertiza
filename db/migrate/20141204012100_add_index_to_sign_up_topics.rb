class AddIndexToSignUpTopics < ActiveRecord::Migration[4.2]
   def self.up
      add_index :sign_up_topics, :assignment_id
   end

  def self.down
    remove_index :sign_up_topics, :assignment_id
  end
end
