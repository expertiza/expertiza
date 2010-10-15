class CreateDueDates < ActiveRecord::Migration
  def self.up
  create_table "due_dates", :force => true do |t|
    t.column "due_at", :datetime
    t.column "deadline_type_id", :integer
    t.column "assignment_id", :integer
    t.column "late_policy_id", :integer
    t.column "submission_allowed_id", :integer
    t.column "review_allowed_id", :integer
    t.column "resubmission_allowed_id", :integer
    t.column "rereview_allowed_id", :integer
    t.column "review_of_review_allowed_id", :integer
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
  add_index "due_dates", ["resubmission_allowed_id"], :name => "idx_resubmission_allowed"
  add_index "due_dates", ["rereview_allowed_id"], :name => "idx_rereview_allowed"
  add_index "due_dates", ["review_of_review_allowed_id"], :name => "idx_review_of_review_allowed"
  
  end

  def self.down
      drop_table "due_dates"
  end
end
