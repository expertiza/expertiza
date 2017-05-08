class ChangeColumnName < ActiveRecord::Migration
  def change
    rename_column :github_contributors, :submission_records_id, :submission_record_id
  end
end
