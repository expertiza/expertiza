class CreateDueDates < ActiveRecord::Migration
  def self.up
    create_table "due_dates", :force => true do |t|
      t.column "due_at", :datetime
      t.column "deadline_type_id", :integer
      t.column "assignment_id", :integer
      t.column "late_policy_id", :integer
      t.column "submission_allowed_id", :integer
      t.column "review_allowed_id", :integer
      t.column "metareview_allowed_id", :integer
      t.column "signup_allowed_id", :integer
      t.column "drop_allowed_id", :integer
      t.column "teammate_review_allowed_id", :integer
      t.column "survey_response_allowed_id", :integer
    end

    add_index "due_dates", ["deadline_type_id"], :name => "fk_deadline_type_due_date"

    execute "alter table due_dates
             add constraint fk_deadline_type_due_date
             foreign key (deadline_type_id) references deadline_types(id)"

    add_index "due_dates", ["assignment_id"], :name => "fk_due_dates_assignments"

    execute "alter table due_dates
             add constraint fk_due_dates_assignments
             foreign key (assignment_id) references assignments(id)"

    add_index "due_dates", ["late_policy_id"], :name => "fk_due_date_late_policies"

    execute "alter table due_dates
             add constraint fk_due_date_late_policies
             foreign key (late_policy_id) references late_policies(id)"

    add_index "due_dates", ["submission_allowed_id"], :name => "idx_submission_allowed"
    add_index "due_dates", ["review_allowed_id"], :name => "idx_review_allowed"
    add_index "due_dates", ["metareview_allowed_id"], :name => "idx_metareview_allowed"
    add_index "due_dates", ["signup_allowed_id"], :name => "idx_signup_allowed_id"
    add_index "due_dates", ["drop_allowed_id"], :name => "idx_drop_allowed_id"
    add_index "due_dates", ["teammate_review_allowed_id"], :name => "idx_teammate_review_allowed_id"
    add_index "due_dates", ["survey_response_allowed_id"], :name => "idx_survey_response_allowed_id"

  end

  def self.down
    drop_table "due_dates"
  end
end
