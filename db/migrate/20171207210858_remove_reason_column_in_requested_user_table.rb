class RemoveReasonColumnInRequestedUserTable < ActiveRecord::Migration[4.2]
  def change
    remove_column :requested_users, :reason
  end
end
