class AddTypeIdToAssignments < ActiveRecord::Migration
  def change
		add_column :assignments, :type_id, :boolean , default: false
  end
end
