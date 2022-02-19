class AddDescriptionToSignUpTopics < ActiveRecord::Migration[4.2]
  def change
    add_column :sign_up_topics, :description, :string
  end
end
