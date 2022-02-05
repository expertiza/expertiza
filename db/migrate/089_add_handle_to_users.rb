class AddHandleToUsers < ActiveRecord::Migration[4.2]
  def self.up
    begin
      add_column :users, :handle, :string, :null => true
    rescue
      put $!
    end    
  end

  def self.down
    begin
      remove_column :users, :handle
    rescue
    end
  end
end
