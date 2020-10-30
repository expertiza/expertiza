class CreateSubmissionViewingEvents < ActiveRecord::Migration
  def change
    create_table :submission_viewing_events do |t|
      t.integer :map_id
      t.integer :round
      t.string :link
      t.datetime :start_at
      t.datetime :end_at

      t.timestamps null: false
    end
  end
end