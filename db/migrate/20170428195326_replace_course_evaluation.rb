class ReplaceCourseEvaluation < ActiveRecord::Migration
  def up
    Questionnaire.where(type: "CourseEvaluationQuestionnaire"){
        | questionnaire |
      Questionnaire.update(questionnaire.id, :type => "CourseSurveyQuestionnaire")
    }
    fnode = TreeFolder.find_by_name('Course Evaluation')
    TreeFolder.update(fnode.id, :name => 'Course Survey')
  end
  def down
    Questionnaire.where(type: "CourseSurveyQuestionnaire"){
        | questionnaire |
      Questionnaire.update(questionnaire.id, :type => "CourseEvaluationQuestionnaire")
    }
    fnode = TreeFolder.find_by_name('Course Survey')
    TreeFolder.update(fnode.id, :name => 'Course Evaluation')
  end
end
