class AddSurveyDeployment < ActiveRecord::Migration
  def self.up
    add_column "survey_responses","survey_deployment_id",:integer
    
  end

  def self.down
    remove_column "survey_responses","survey_deployment_id"
  end
end
