class AddIndexToSignUpTopics < ActiveRecord::Migration
   def self.up
      add_index :sign_up_topics, :assignment_id
   end

   def self.down
   	remove_index :sign_up_topics, :assignment_id
   end
end
