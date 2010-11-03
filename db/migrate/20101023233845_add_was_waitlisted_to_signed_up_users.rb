class AddWasWaitlistedToSignedUpUsers < ActiveRecord::Migration
  def self.up
    add_column :signed_up_users, :was_waitlisted, :boolean  
  end

  def self.down
    remove_column :signed_up_users, :was_waitlisted
  end
end
