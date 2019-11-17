class AddActionsEnableToUsers < ActiveRecord::Migration
  def change
    add_column :users, :action_enable, :boolean, default: true
  end
end
