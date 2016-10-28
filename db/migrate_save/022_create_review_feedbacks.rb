class CreateReviewFeedbacks < ActiveRecord::Migration
  def self.up
    create_table :review_feedbacks do |t|
      # Note: Table name pluralized by convention.  Do *NOT* refer to "feedbacks" in any documentation!
      t.column :assignment_id, :integer  # the assignment to which this feedback pertains.
      t.column :review_id, :integer  # the review to which this feedback pertains; if it is null, the feedback is general, for all reviewers.
      t.column :user_id, :integer # ID of the user making the feedback.  Typically this will be the author of the submission, but it may be, e.g., the instructor or TA.
      t.column :feedback_at, :datetime  # time that the feedback was saved
      t.column :txt, :text
    end
    execute "alter table review_feedbacks
             add constraint fk_review_feedback_assignments
             foreign key (assignment_id) references assignments(id)"
    execute "alter table review_feedbacks  # is it possible to have a constraint and still have a null value in field?
             add constraint fk_review_feedback_reviews
             foreign key (review_id) references reviews(id)"
  end

  def self.down
    drop_table :review_feedbacks
  end
end
