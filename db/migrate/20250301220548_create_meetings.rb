class CreateMeetings < ActiveRecord::Migration[5.1]
  def change
    create_table :meetings do |t|
      t.datetime :meeting_date
      t.string :team_id

      t.timestamps
    end
  end
end
