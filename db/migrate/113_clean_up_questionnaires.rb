class CleanUpQuestionnaires < ActiveRecord::Migration
  def self.up    
    Questionnaire.find_by_sql("select q.* 
      from questionnaires q
      LEFT JOIN assignment_questionnaires aq ON q.id = aq.questionnaire_id
      LEFT JOIN assignments a ON a.id = aq.assignment_id
      WHERE a.id is NULL and type not in ('SurveyQuestionnaire','CourseEvaluationQuestionnaire','GlobalSurveyQuestionnaire')").each{
       | questionnaire |
       Question.find_all_by_questionnaire_id(questionnaire.id).each{
          | question |
          QuestionAdvice.find_all_by_question_id(question.id).each{
            | advice |
            advice.destroy
          }
          question.destroy
       }
       questionnaire.delete
    }
  end

  def self.down
  end
end
