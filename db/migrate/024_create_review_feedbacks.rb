class CreateReviewFeedbacks < ActiveRecord::Migration
  def self.up
  create_table "review_feedbacks", :force => true do |t|
    t.column "assignment_id", :integer
    t.column "review_id", :integer
    t.column "user_id", :integer
    t.column "feedback_at", :datetime
    t.column "txt", :text
  end

  add_index "review_feedbacks", ["assignment_id"], :name => "fk_review_feedback_assignments"

  execute "alter table review_feedbacks
             add constraint fk_review_feedback_assignments
             foreign key (assignment_id) references assignments(id)"

  add_index "review_feedbacks", ["review_id"], :name => "fk_review_feedback_reviews"

  execute "alter table review_feedbacks 
             add constraint fk_review_feedback_reviews
             foreign key (review_id) references reviews(id)"

  end

  def self.down
    drop_table "review_feedbacks"
  end
end
