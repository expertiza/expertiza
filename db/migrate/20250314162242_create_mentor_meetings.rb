class CreateMentorMeetings < ActiveRecord::Migration[5.1]
  def change
    create_table :mentor_meetings do |t|
      t.integer :team_id
      t.datetime :meeting_date

      t.timestamps
    end
  end
end
