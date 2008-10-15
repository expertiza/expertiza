class RelocateToScoresTable < ActiveRecord::Migration
  def self.up
    execute " insert into scores (instance_id, question_id, score, comments, questionnaire_type_id) select  
    review_id, question_id, score, comments, 1 from review_scores where questionnaire_type_id = 1"
    
    execute " insert into scores (instance_id, question_id, score, comments, questionnaire_type_id) 
    select  review_id, question_id, score, comments, 5 from review_scores where questionnaire_type_id =5"
            
    execute "insert into scores (instance_id, question_id, score, comments, questionnaire_type_id) 
    select  review_of_review_id, question_id, score, comments,6 from review_of_review_scores"
    
    execute "insert into scores (instance_id, question_id, score, comments, questionnaire_type_id) 
    select  teammate_review_id, question_id, score, comments,7 from teammate_review_scores"
    
    drop_table :teammate_review_scores
    drop_table :review_of_review_scores
    drop_table :review_scores    
    
  end

  def self.down
    
  end
end
