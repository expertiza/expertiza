class AddColumnsToAssignment < ActiveRecord::Migration
  def change
    add_column :assignments, :isAnonymous, :boolean
    add_column :assignments, :group_size, :integer
    add_column :assignments, :auto_generate_groups, :boolean
  end
end
