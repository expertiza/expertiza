class RenameLocalDbScoresColumn < ActiveRecord::Migration
  def change
    rename_column :local_db_scores, :review_type, :type
  end
end
