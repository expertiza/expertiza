class AddLinkToSignUpTopics < ActiveRecord::Migration
  def change
    add_column :sign_up_topics, :link, :string
  end
end
