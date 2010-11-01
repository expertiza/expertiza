class AddDescriptionToSignUpTopic < ActiveRecord::Migration
  #self explanatory. Adding column description to the signuptopic table.
  def self.up
    add_column :sign_up_topics, :description, :text, :null => false
  end

  def self.down
    remove_column :sign_up_topics, :description
  end
end
