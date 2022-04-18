class CreateSubmissionViewingEvents < ActiveRecord::Migration[4.2]
  def change
    create_table :submission_viewing_events do |t|
      t.integer  "map_id",     limit: 4
      t.integer  "round",      limit: 4
      t.string   "link",       limit: 255
      t.datetime "start_at"
      t.datetime "end_at"
      t.timestamps null: false
    end
  end
end
