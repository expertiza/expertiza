class CreateReviewOfReviewScores < ActiveRecord::Migration
  def self.up
    create_table :review_of_review_scores do |t|
      t.column :review_of_review_id, :integer
      t.column :question_id, :integer
      t.column :score, :integer
      t.column :comments, :text
    end
    execute "alter table review_of_review_scores
             add constraint fk_review_of_review_score_reviews
             foreign key (review_of_review_id) references review_of_reviews(id)"
    execute "alter table review_of_review_scores
             add constraint fk_review_of_review_score_questions
             foreign key (question_id) references questions(id)"
  end

  def self.down
    drop_table :review_of_review_scores
  end
end
