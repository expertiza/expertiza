class CreateTrackNotificationsTable < ActiveRecord::Migration[4.2]
  def change
    create_table :track_notifications, id: :integer, auto_increment: true do |t|
      t.integer :notification
      t.integer :user_id
      t.timestamps null: false
    end
  end
end
