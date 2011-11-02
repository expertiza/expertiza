class CreateReviewOfReviewScores < ActiveRecord::Migration
  def self.up
  create_table "metareview_scores", :force => true do |t|
    t.column "metareview_id", :integer
    t.column "question_id", :integer
    t.column "score", :integer
    t.column "comments", :text
  end

  add_index "metareview_scores", ["metareview_id"], :name => "fk_metareview_score_reviews"

  execute "alter table metareview_scores
             add constraint fk_metareview_score_reviews
             foreign key (metareview_id) references metareviews(id)"
             
  add_index "metareview_scores", ["question_id"], :name => "fk_metareview_score_questions"

  execute "alter table metareview_scores
             add constraint fk_metareview_score_questions
             foreign key (question_id) references questions(id)"
             
  end

  def self.down
    drop_table "metareview_scores"
  end
end
