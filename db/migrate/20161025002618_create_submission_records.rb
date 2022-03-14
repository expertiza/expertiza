class CreateSubmissionRecords < ActiveRecord::Migration[4.2]
  def change
    create_table :submission_records, id: :integer do |t|
      t.timestamps null: false
    end
  end
end
