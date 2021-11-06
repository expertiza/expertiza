class CreateSubmissionRecords < ActiveRecord::Migration
  def change
    create_table :submission_records do |t|

      t.timestamps null: false
    end
  end
end
