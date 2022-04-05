class CleanUpQuestionnaires < ActiveRecord::Migration[4.2]
  def self.up    
    Questionnaire.find_by_sql("select q.* 
      from questionnaires q
      LEFT JOIN assignment_questionnaires aq ON q.id = aq.questionnaire_id
      LEFT JOIN assignments a ON a.id = aq.assignment_id
      WHERE a.id is NULL and type not in ('SurveyQuestionnaire','CourseEvaluationQuestionnaire','GlobalSurveyQuestionnaire')").each do |questionnaire|
      Question.where(questionnaire_id: questionnaire.id).each do |question|
        QuestionAdvice.where(question_id: question.id).each(&:destroy)
        question.destroy
      end
      questionnaire.delete
    end
  end

  def self.down; end
end
