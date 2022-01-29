class RemoveSurveyEntriesAndTables < ActiveRecord::Migration
  def change
    drop_table :survey_deployments
    Questionnaire.where(type: "AssignmentSurveyQuestionnaire").destroy_all
    Questionnaire.where(type: "CourseSurveyQuestionnaire").destroy_all
    Questionnaire.where(type: "GlobalSurveyQuestionnaire").destroy_all
  end
end
