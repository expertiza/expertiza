class AddLoginattemptsNextloginToUsers < ActiveRecord::Migration
  def change
  add_column :users, :login_attempts, :integer, default: 0
  add_column :users, :next_login_time, :datetime, default: DateTime.now
  end
end
