class AddTypeToSurveyDeployments < ActiveRecord::Migration[4.2]
  def change
    add_column :survey_deployments, :type, :string
  end
end
