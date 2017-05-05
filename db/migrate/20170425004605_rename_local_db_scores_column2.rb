class RenameLocalDbScoresColumn2 < ActiveRecord::Migration
  def change
    rename_column :local_db_scores, :type, :score_type
  end
end
