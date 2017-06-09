class UpdateSurveyQuestionnaireToAssignmentSurveyQuestionnaire < ActiveRecord::Migration
  def change
    execute "UPDATE questionnaires set type = 'AssignmentSurveyQuestionnaire' where type in ('SurveyQuestionnaire')"
  end
end
