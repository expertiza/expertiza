class DropTableSurveyDeployments < ActiveRecord::Migration
  def change
    drop_table :survey_deployments
  end
end