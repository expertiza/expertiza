class AddTimestampToSignedUpUsers < ActiveRecord::Migration
  def self.up
    add_column :signed_up_users, :created_at, :datetime
    add_column :signed_up_users, :updated_at, :datetime
  end

  def self.down
    remove_column :signed_up_users, :created_at
    remove_column :signed_up_users, :updated_at
  end
end
