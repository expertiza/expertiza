class CreateReviewScores < ActiveRecord::Migration
  def self.up
  create_table "review_scores", :force => true do |t|
    t.column "review_id", :integer
    t.column "question_id", :integer
    t.column "score", :integer
    t.column "comments", :text
  end

  add_index "review_scores", ["review_id"], :name => "fk_review_score_reviews"

  execute "alter table review_scores
             add constraint fk_review_score_reviews
             foreign key (review_id) references reviews(id)"

  add_index "review_scores", ["question_id"], :name => "fk_review_score_questions"

  execute "alter table review_scores
             add constraint fk_review_score_questions
             foreign key (question_id) references questions(id)"

  end

  def self.down
    drop_table "review_scores"
  end
end
