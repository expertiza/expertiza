class KillSurveyResponseTable < ActiveRecord::Migration
  def change
    drop_table :survey_responses
  end
end
