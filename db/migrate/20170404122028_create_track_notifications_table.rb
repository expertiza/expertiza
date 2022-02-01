class CreateTrackNotificationsTable < ActiveRecord::Migration[4.2]
  def change
    create_table :track_notifications do |t|
      t.integer :notification
      t.integer :user_id
      t.timestamps null: false
    end
  end
end
