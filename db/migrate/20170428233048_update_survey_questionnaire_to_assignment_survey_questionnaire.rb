class UpdateSurveyQuestionnaireToAssignmentSurveyQuestionnaire < ActiveRecord::Migration[4.2]
  def change
    execute "UPDATE questionnaires set type = 'AssignmentSurveyQuestionnaire' where type in ('SurveyQuestionnaire')"
  end
end
