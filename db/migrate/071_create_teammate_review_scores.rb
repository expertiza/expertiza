class CreateTeammateReviewScores < ActiveRecord::Migration
  def self.up
    create_table :teammate_review_scores do |t|
      # Note: Table name pluralized by convention.
      t.column "teammate_review_id", :integer
      t.column "question_id", :integer
      t.column "score", :integer
      t.column "comments", :text
    end
    
    add_index "teammate_review_scores", ["teammate_review_id"], :name => "fk_teammate_review_score_teammate_reviews"

    execute "alter table teammate_review_scores 
               add constraint fk_teammate_review_score_teammate_reviews
               foreign key (teammate_review_id) references teammate_reviews(id)"
               
    add_index "teammate_review_scores", ["question_id"], :name => "fk_teammate_review_score_questions"

    execute "alter table teammate_review_scores 
               add constraint fk_teammate_review_score_questions
               foreign key (question_id) references questions(id)"
  end

  def self.down
    drop_table :teammate_review_scores
  end
end
