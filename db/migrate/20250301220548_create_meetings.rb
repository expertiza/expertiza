class CreateMeetings < ActiveRecord::Migration[5.1]
  def change
    create_table :meetings do |t|
      t.datetime :Date
      t.string :TeamID

      t.timestamps
    end
  end
end
