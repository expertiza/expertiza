class RemoveSubmissionrecords < ActiveRecord::Migration[4.2]
  def change
    drop_table :submissionrecords
  end
end
