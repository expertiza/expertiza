class CorrectQuestionnaireTypeInReviewScores < ActiveRecord::Migration
  def self.up
    review_rubric_id = QuestionnaireType.find_by_name('Review Rubric').id
    author_feedback_id =  QuestionnaireType.find_by_name('Author Feedback').id
    execute "update `review_scores` set questionnaire_type_id = "+review_rubric_id.to_s+" where questionnaire_type_id is null"
    execute "update `review_scores` set questionnaire_type_id = "+author_feedback_id.to_s+" where questionnaire_type_id = 4"    
  end

  def self.down
  end
end
