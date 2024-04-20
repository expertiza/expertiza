class AddMentorToSignUpTopics < ActiveRecord::Migration[5.1]
  def change
    add_column :sign_up_topics, :mentor_id, :integer
    add_foreign_key :sign_up_topics, :users, column: :mentor_id, on_delete: :nullify
    add_index :sign_up_topics, :mentor_id, name: "index_sign_up_topics_on_mentor_id"
    change_column_default :sign_up_topics, :mentor_id, from: nil, to: nil
  end
end
