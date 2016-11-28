class AddTeamIdColumnToSubmissionrecord < ActiveRecord::Migration
  def change
    add_column :submission_records, :assignment_id, :integer
  end
end
