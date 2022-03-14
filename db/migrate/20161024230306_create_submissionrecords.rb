class CreateSubmissionrecords < ActiveRecord::Migration[4.2]
  def change
    create_table :submissionrecords, id: :integer, auto_increment: true do |t|
      t.timestamps null: false
    end
  end
end
