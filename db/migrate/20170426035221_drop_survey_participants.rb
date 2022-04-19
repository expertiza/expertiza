class DropSurveyParticipants < ActiveRecord::Migration
  def change
    drop_table :survey_participants
  end
end
