class AddAttributesToSubmissionrecords < ActiveRecord::Migration[4.2]
  def change
    add_column :submissionrecords, :type, :text
    add_column :submissionrecords, :content, :string
    add_column :submissionrecords, :createdat, :datetime
    add_column :submissionrecords, :operation, :string
    add_column :submissionrecords, :team_id, :integer
    add_column :submissionrecords, :user, :string
  end
end
