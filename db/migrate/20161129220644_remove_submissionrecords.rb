class RemoveSubmissionrecords < ActiveRecord::Migration
  def change
    drop_table :submissionrecords
  end
end
