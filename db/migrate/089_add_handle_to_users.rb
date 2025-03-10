class AddHandleToUsers < ActiveRecord::Migration[4.2]
  def self.up
    add_column :users, :handle, :string, null: true
  rescue StandardError
    put $ERROR_INFO
  end

  def self.down
    remove_column :users, :handle
  rescue StandardError
  end
end
