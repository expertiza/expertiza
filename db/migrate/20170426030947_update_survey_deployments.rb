class UpdateSurveyDeployments < ActiveRecord::Migration[4.2]
  change_table :survey_deployments do |t|
    t.rename :course_id, :parent_id
    t.rename :course_evaluation_id, :questionnaire_id
  end

  def change
    add_column :survey_deployments, :global_survey_id, :integer, null: true
    add_foreign_key :survey_deployments, :questionnaires
  end
end
