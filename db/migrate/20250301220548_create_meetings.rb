class CreateMeetings < ActiveRecord::Migration[5.1]
  def change
    create_table :meetings do |t|
      t.date :meeting_date
      t.integer :team_id, foreign_key: true # Add foreign_key: true

      t.timestamps
    end
  end
end
