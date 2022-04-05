class AddingAttributesSubmissionCode < ActiveRecord::Migration[4.2]
  def change
    add_column :submission_records, :type, :text
    add_column :submission_records, :content, :string
    add_column :submission_records, :createdat, :datetime
    add_column :submission_records, :operation, :string
    add_column :submission_records, :team_id, :integer
    add_column :submission_records, :user, :string
  end
end
