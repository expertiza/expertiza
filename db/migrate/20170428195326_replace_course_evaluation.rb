class ReplaceCourseEvaluation < ActiveRecord::Migration[4.2]
  def up
    Questionnaire.where(type: 'CourseEvaluationQuestionnaire') do |questionnaire|
      Questionnaire.update(questionnaire.id, type: 'CourseSurveyQuestionnaire')
    end
    fnode = TreeFolder.find_by_name('Course Evaluation')
    TreeFolder.update(fnode.id, name: 'Course Survey')
  end

  def down
    Questionnaire.where(type: 'CourseSurveyQuestionnaire') do |questionnaire|
      Questionnaire.update(questionnaire.id, type: 'CourseEvaluationQuestionnaire')
    end
    fnode = TreeFolder.find_by_name('Course Survey')
    TreeFolder.update(fnode.id, name: 'Course Evaluation')
  end
end
