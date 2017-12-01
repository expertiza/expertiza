class AddTrelloNameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :trello_name, :string
  end
end
