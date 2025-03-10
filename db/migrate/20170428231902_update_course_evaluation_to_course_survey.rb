class UpdateCourseEvaluationToCourseSurvey < ActiveRecord::Migration[4.2]
  def change
    execute "UPDATE questionnaires set type = 'CourseSurveyQuestionnaire' where type in ('CourseEvaluationQuestionnaire')"
  end
end
