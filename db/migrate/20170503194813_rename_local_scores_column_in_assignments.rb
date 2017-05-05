class RenameLocalScoresColumnInAssignments < ActiveRecord::Migration
  def change
    rename_column :assignments, :local_scores_calculated, :local_scores_stored
  end
end
