class RemoveReasonColumnInRequestedUserTable < ActiveRecord::Migration
  def change
  	remove_column :requested_users, :reason
  end
end
