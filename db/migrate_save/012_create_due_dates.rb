class CreateDueDates < ActiveRecord::Migration
  def self.up
    create_table :due_dates do |t|
	t.column :due_at, :datetime
	t.column :deadline_type_id, :integer # whether a submission deadline, a review deadline, etc.
	t.column :assignment_id, :integer # the assignment that this due date pertains to
	t.column :late_policy_id, :integer # specifies how many points/percent taken off for a particular amt. of lateness
	t.column :submission_allowed_id, :integer # this is "OK", "Late" or "No", depending on whether submission is allowed before this due date
	t.column :review_allowed_id, :integer # this is "OK", "Late" or "No", depending on whether reviewing is allowed before this due date
	t.column :resubmission_allowed_id, :integer
	t.column :rereview_allowed_id, :integer # controls whether a version submitted since last review deadline may be reviewed now
	t.column :review_of_review_allowed_id, :integer
    end
    execute "alter table due_dates
             add constraint fk_deadline_type_due_date
             foreign key (deadline_type_id) references deadline_types(id)"
    execute "alter table due_dates 
             add constraint fk_due_dates_assignments
             foreign key (assignment_id) references assignments(id)"
    execute "alter table due_dates
             add constraint fk_due_date_late_policies
             foreign key (late_policy_id) references late_policies(id)"
    execute "alter table due_dates
             add constraint fk_due_date_submission_allowed
             foreign key (submission_allowed_id) references deadline_rights(id)"
    execute "alter table due_dates
             add constraint fk_due_date_review_allowed
             foreign key (review_allowed_id) references deadline_rights(id)"
    execute "alter table due_dates
             add constraint fk_due_date_resubmission_allowed
             foreign key (resubmission_allowed_id) references deadline_rights(id)"
    execute "alter table due_dates
             add constraint fk_due_date_rereview_allowed
             foreign key (rereview_allowed_id) references deadline_rights(id)"
    execute "alter table due_dates
             add constraint fk_due_date_review_of_review_allowed
             foreign key (review_of_review_allowed_id) references deadline_rights(id)"
  end

  def self.down
    drop_table :due_dates
  end
end
