class RemoveAssignmentId < ActiveRecord::Migration
  def change
  	add_column :duties, :assignment_id, :integer
  end
end
