class AddPrivateToLatePolicies < ActiveRecord::Migration
  def change
    add_column :late_policies, :private, :bool, :null => false, :default => true
  end
end
