class RelocateToScoresTable < ActiveRecord::Migration
  def self.up
    begin
    execute " insert into scores (instance_id, question_id, score, comments, questionnaire_type_id) select  
    review_id, question_id, score, comments, 1 from review_scores where questionnaire_type_id = 1"
    rescue
  end
    begin
    execute " insert into scores (instance_id, question_id, score, comments, questionnaire_type_id) 
    select  review_id, question_id, score, comments, 5 from review_scores where questionnaire_type_id =5"
         rescue
     end
     begin
    execute "insert into scores (instance_id, question_id, score, comments, questionnaire_type_id) 
    select  review_of_review_id, question_id, score, comments,6 from review_of_review_scores"
    rescue
  end
    begin
    execute "insert into scores (instance_id, question_id, score, comments, questionnaire_type_id) 
    select  teammate_review_id, question_id, score, comments,7 from teammate_review_scores"
    rescue
  end
    begin  
    drop_table :teammate_review_scores
    rescue
  end
    begin
    drop_table :review_of_review_scores
    rescue
  end
    begin
    drop_table :review_scores
    rescue
       end
    
  end

  def self.down
    
  end
end
