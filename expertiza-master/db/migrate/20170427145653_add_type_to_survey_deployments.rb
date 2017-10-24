class AddTypeToSurveyDeployments < ActiveRecord::Migration
  def change
    add_column :survey_deployments, :type, :string
  end
end
