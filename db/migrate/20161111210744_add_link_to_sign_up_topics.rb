class AddLinkToSignUpTopics < ActiveRecord::Migration[4.2]
  def change
    add_column :sign_up_topics, :link, :string
  end
end
