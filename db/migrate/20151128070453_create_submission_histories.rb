class CreateSubmissionHistories < ActiveRecord::Migration
  def change
    create_table :submission_histories do |t|
      t.references :participant, index: true, foreign_key: true
      t.text :artifact_name
      t.text :artifact_type
      t.text :event
      t.datetime :event_time

      t.timestamps null: false
    end
  end
end
