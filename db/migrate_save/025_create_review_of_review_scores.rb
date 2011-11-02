class CreateReviewOfReviewScores < ActiveRecord::Migration
  def self.up
    create_table :metareview_scores do |t|
      t.column :metareview_id, :integer
      t.column :question_id, :integer
      t.column :score, :integer
      t.column :comments, :text
    end
    execute "alter table metareview_scores
             add constraint fk_metareview_score_reviews
             foreign key (metareview_id) references metareviews(id)"
    execute "alter table metareview_scores
             add constraint fk_metareview_score_questions
             foreign key (question_id) references questions(id)"
  end

  def self.down
    drop_table :metareview_scores
  end
end
