class CreateAssignments < ActiveRecord::Migration
  def self.up
    create_table :assignments do |t|
	t.column :name, :string
	t.column :directory_path, :string
	t.column :submitter_count, :integer, :default => 0 # number of people who have submitted to this assgt. so far; initialized to 0
    t.column :course_id, :integer # id of course (if any) that this assignment is associated with
	t.column :instructor_id, :integer # id of instructor who created the assignment
	t.column :private, :boolean  # whether assignment is visible to other instructors
    t.column :num_reviewers, :integer # number of people who review each submission for this assgt.
    t.column :num_review_of_reviewers, :integer # number of people who review each review for this assgt.
	t.column :review_questionnaire_id, :integer
	t.column :review_of_review_questionnaire_id, :integer
	t.column :review_weight, :float # the percentage that reviews count for; the balance of grade depends on reviews of reviews
	t.column :reviews_visible_to_all, :boolean # if false, other reviewers can't see this reviewer's review
	t.column :team_assignment, :boolean
	t.column :wiki_assignment, :boolean
	t.column :require_signup, :boolean # if true, users need to sign up thru Shimmer before submitting; if false, everyone in course may submit; if assgt. not in course, default is that no one may submit
    end
    execute "alter table assignments 
             add constraint fk_assignments_review_questionnaires
             foreign key (review_questionnaire_id) references questionnaires(id)"
    execute "alter table assignments
             add constraint fk_assignments_review_of_review_questionnaires
             foreign key (review_of_review_questionnaire_id) references questionnaires(id)"
    execute "alter table assignments
             add constraint fk_assignments_instructors
             foreign key (instructor_id) references users(id)"
  end

  def self.down
    drop_table :assignments
  end
end
