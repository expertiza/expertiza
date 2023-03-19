class DeleteOriginalTrackNotificationsTableAndCreateANewOneWithCorrectFields < ActiveRecord::Migration[4.2]
  def change
    drop_table :track_notifications
    create_table :track_notifications do |t|
      t.references :notification, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
