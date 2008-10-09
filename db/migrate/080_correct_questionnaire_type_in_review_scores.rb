class CorrectQuestionnaireTypeInReviewScores < ActiveRecord::Migration
  def self.up
    ReviewScore.find(:all).each{
       |entry|
       if entry.questionnaire_type_id.nil?
         entry.questionnaire_type_id = QuestionnaireType.find_by_name('Review Rubric').id
       elsif entry.questionnaire_type_id == 4
         entry.questionnaire_type_id = QuestionnaireType.find_by_name('Author Feedback').id
       end
       entry.save
    }
  end

  def self.down
  end
end
