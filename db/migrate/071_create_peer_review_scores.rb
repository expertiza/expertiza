class CreatePeerReviewScores < ActiveRecord::Migration
  def self.up
    create_table :peer_review_scores do |t|
      # Note: Table name pluralized by convention.
      t.column "peer_review_id", :integer
      t.column "question_id", :integer
      t.column "score", :integer
      t.column "comments", :text
    end
    
    add_index "peer_review_scores", ["peer_review_id"], :name => "fk_peer_review_score_peer_reviews"

    execute "alter table peer_review_scores 
               add constraint fk_peer_review_score_peer_reviews
               foreign key (peer_review_id) references peer_reviews(id)"
               
    add_index "peer_review_scores", ["question_id"], :name => "fk_peer_review_score_questions"

    execute "alter table peer_review_scores 
               add constraint fk_peer_review_score_questions
               foreign key (question_id) references questions(id)"
  end

  def self.down
    drop_table :peer_review_scores
  end
end
