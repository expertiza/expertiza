class AddMentorIdToSignUpTopics < ActiveRecord::Migration[5.1]
  def change
    add_column :sign_up_topics, :mentor_id, :integer
    add_foreign_key :sign_up_topics, :users, column: :mentor_id # Add foreign key
    add_index :sign_up_topics, :mentor_id             # Add index
  end
end
