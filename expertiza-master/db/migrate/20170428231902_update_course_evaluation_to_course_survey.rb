class UpdateCourseEvaluationToCourseSurvey < ActiveRecord::Migration
  def change
    execute "UPDATE questionnaires set type = 'CourseSurveyQuestionnaire' where type in ('CourseEvaluationQuestionnaire')"
  end
end
