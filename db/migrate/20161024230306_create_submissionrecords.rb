class CreateSubmissionrecords < ActiveRecord::Migration[4.2]
  def change
    create_table :submissionrecords, id: :integer do |t|
      t.timestamps null: false
    end
  end
end
