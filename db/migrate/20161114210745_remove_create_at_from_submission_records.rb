class RemoveCreateAtFromSubmissionRecords < ActiveRecord::Migration[4.2]
  def change
    remove_column :submission_records, :createdat
  end
end
