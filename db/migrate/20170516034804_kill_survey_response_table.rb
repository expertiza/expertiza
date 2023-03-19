class KillSurveyResponseTable < ActiveRecord::Migration[4.2]
  def change
    drop_table :survey_responses
  end
end
