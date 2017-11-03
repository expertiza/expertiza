class AddDescriptionToSignUpTopics < ActiveRecord::Migration
  def change
    add_column :sign_up_topics, :description, :string
  end
end
