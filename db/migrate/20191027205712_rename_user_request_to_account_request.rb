class RenameUserRequestToAccountRequest < ActiveRecord::Migration[4.2]
  def change
    rename_table :requested_users, :account_requests
  end
end
