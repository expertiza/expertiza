class ChangeDescriptionTypeInSignUpTopics < ActiveRecord::Migration[4.2]
  def change
    change_column :sign_up_topics, :description, :text
  end
end
