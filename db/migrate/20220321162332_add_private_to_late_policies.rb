class AddPrivateToLatePolicies < ActiveRecord::Migration[4.2]
  def change
    add_column :late_policies, :private, :bool, :null => false, :default => true
  end
end
