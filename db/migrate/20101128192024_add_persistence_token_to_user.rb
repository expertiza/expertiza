class AddPersistenceTokenToUser < ActiveRecord::Migration[4.2]
  def self.up
    add_column :users, :persistence_token, :string
  end

  def self.down
    remove_column :users, :persistence_token
  end
end
