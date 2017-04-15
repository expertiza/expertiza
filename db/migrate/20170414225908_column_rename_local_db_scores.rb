class ColumnRenameLocalDbScores < ActiveRecord::Migration
  def change
    rename_column :local_db_scores, :type, :review_type
  end
end
