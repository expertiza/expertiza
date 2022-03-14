class CreateSubmissionRecords < ActiveRecord::Migration[4.2]
  def change
    create_table :submission_records, id: :integer, auto_increment: true do |t|
      t.timestamps null: false
    end
  end
end
