class RemoveReasonColumnInRequestedUserTable < ActiveRecord::Migration
  def change
  	remove_column :account_requests, :reason
  end
end
