class CreateReviewScores < ActiveRecord::Migration
  def self.up
    create_table :review_scores do |t|
      t.column :review_id, :integer
      t.column :question_id, :integer
      t.column :score, :integer
      t.column :comments, :text
    end
    execute "alter table review_scores
             add constraint fk_review_score_reviews
             foreign key (review_id) references reviews(id)"
    execute "alter table review_scores
             add constraint fk_review_score_questions
             foreign key (question_id) references questions(id)"
  end

  def self.down
    drop_table :review_scores
  end
end
