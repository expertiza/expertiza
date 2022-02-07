class CorrectQuestionnaireTypeInReviewScores < ActiveRecord::Migration
  def self.up
    review_rubric = ActiveRecord::Base.connection.select_one("select * from questionnaire_types where name = 'Review Rubric'")          
    
    if review_rubric 
      execute "update `review_scores` set questionnaire_type_id = "+review_rubric["id"].to_s+" where questionnaire_type_id is null"    
    end
    author_feedback = ActiveRecord::Base.connection.select_one("select * from questionnaire_types where name = 'Author Feedback'")              
    if author_feedback
      execute "update `review_scores` set questionnaire_type_id = "+author_feedback["id"].to_s+" where questionnaire_type_id = 4"
    end
  end

  def self.down
  end
end
