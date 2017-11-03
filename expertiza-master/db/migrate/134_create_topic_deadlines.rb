class CreateTopicDeadlines < ActiveRecord::Migration
  def self.up
    create_table :topic_deadlines do |t|
      t.column "due_at", :datetime
      t.column "deadline_type_id", :integer
      t.column "topic_id", :integer
      t.column "late_policy_id", :integer
      t.column "submission_allowed_id", :integer
      t.column "review_allowed_id", :integer
      t.column "resubmission_allowed_id", :integer
      t.column "rereview_allowed_id", :integer
      t.column "review_of_review_allowed_id", :integer
      t.column "round", :integer
    end

    # fails to execute
    #execute "alter table topic_deadlines
    #         add constraint fk_deadline_type_due_date
    #         foreign key (deadline_type_id) references deadline_types(id)"

    execute "alter table topic_deadlines
             add constraint fk_topic_deadlines_topics
             foreign key (topic_id) references sign_up_topics(id)"
    
    # fails to execute
    #execute "alter table topic_deadlines
    #         add constraint fk_due_date_late_policies
    #         foreign key (late_policy_id) references late_policies(id)"

    add_index "topic_deadlines", ["submission_allowed_id"], :name => "idx_submission_allowed"
    add_index "topic_deadlines", ["review_allowed_id"], :name => "idx_review_allowed"
    add_index "topic_deadlines", ["resubmission_allowed_id"], :name => "idx_resubmission_allowed"
    add_index "topic_deadlines", ["rereview_allowed_id"], :name => "idx_rereview_allowed"
    add_index "topic_deadlines", ["review_of_review_allowed_id"], :name => "idx_review_of_review_allowed"
  end

  def self.down
    drop_table :topic_deadlines
  end
end
