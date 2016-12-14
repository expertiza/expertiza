class ChangeDescriptionTypeInSignUpTopics < ActiveRecord::Migration
  def change
    change_column :sign_up_topics, :description, :text
  end
end
