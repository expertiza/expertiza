class UpdateReviewScores < ActiveRecord::Migration
  def self.up
    add_column "review_scores","questionnaire_type_id",:integer

    execute "ALTER TABLE review_scores 
             ADD CONSTRAINT fk_review_scores_questionnaire_type_id
             FOREIGN KEY (questionnaire_type_id) references questionnaire_types(id)"
  end

  def self.down
    execute "ALTER TABLE review_scores 
             DROP FOREIGN KEY fk_review_scores_questionnaire_type_id"
    
    remove_column "review_scores","questionnaire_type_id"
  end
end
