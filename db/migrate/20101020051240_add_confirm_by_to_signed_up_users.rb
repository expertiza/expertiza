class AddConfirmByToSignedUpUsers < ActiveRecord::Migration
  def self.up
    add_column :signed_up_users, :confirm_by, :int
  end

  def self.down
    remove_column :signed_up_users, :confirm_by
  end
end
