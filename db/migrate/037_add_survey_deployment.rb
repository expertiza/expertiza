class AddSurveyDeployment < ActiveRecord::Migration
  def self.up
    add_column "survey_responses","survey_deployment_id",:integer
    
  end

  def self.down
    
  end
end
