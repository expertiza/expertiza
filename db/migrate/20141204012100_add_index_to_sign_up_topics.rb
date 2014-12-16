class AddIndexToSignUpTopics < ActiveRecord::Migration
   def change
      add_index :sign_up_topics, :assignment_id
   end
end
