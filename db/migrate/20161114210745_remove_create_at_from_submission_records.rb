class RemoveCreateAtFromSubmissionRecords < ActiveRecord::Migration
  def change
    remove_column :submission_records, :createdat
  end
end
