class DropSurveyParticipants < ActiveRecord::Migration[4.2]
  def change
    drop_table :survey_participants
  end
end
