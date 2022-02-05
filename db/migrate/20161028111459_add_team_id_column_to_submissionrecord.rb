class AddTeamIdColumnToSubmissionrecord < ActiveRecord::Migration[4.2]
  def change
    add_column :submission_records, :assignment_id, :integer
  end
end
