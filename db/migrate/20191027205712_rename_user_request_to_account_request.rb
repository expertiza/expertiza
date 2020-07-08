class RenameUserRequestToAccountRequest < ActiveRecord::Migration
  def change
    rename_table :requested_users, :account_requests
  end
end
