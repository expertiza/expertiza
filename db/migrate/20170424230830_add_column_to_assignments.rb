class AddColumnToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :local_scores_calculated, :boolean
  end
end
