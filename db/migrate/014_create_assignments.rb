class CreateAssignments < ActiveRecord::Migration
  def self.up
    create_table :assignments do |t|
	t.column :created_at, :datetime  # time that the assignment was created
    t.column :updated_at, :datetime  # time that the assignment was updated
	t.column :name, :string
	t.column :directory_path, :string
	t.column :submitter_count, :integer, :default => 0 # number of people who have submitted to this assgt. so far; initialized to 0
    t.column :course_id, :integer # id of course (if any) that this assignment is associated with
	t.column :instructor_id, :integer # id of instructor who created the assignment
	t.column :private, :boolean  # whether assignment is visible to other instructors
    t.column :num_reviews, :integer # number of reviews done by a student for this assignment
    t.column :num_review_of_reviews, :integer # number of reviews of reviews done by a student for this assgt.
    t.column :review_strategy_id, :integer # the review strategy, e.g., "rubric", "ranking"
    t.column :mapping_strategy_id, :integer # the review-mapping strategy, e.g., "static", "dynamic"
	t.column :review_rubric_id, :integer
	t.column :review_of_review_rubric_id, :integer
	t.column :review_weight, :float # the percentage that reviews count for; the balance of grade depends on reviews of reviews
	t.column :reviews_visible_to_all, :boolean # if false, other reviewers can't see this reviewer's review
	t.column :team_assignment, :boolean
	t.column :wiki_type_id, :integer # id of wiki assignment type
	t.column :require_signup, :boolean # if true, users need to sign up thru Shimmer before submitting; if false, everyone in course may submit; if assgt. not in course, default is that no one may submit
    end
    execute "alter table assignments 
             add constraint fk_assignments_review_rubrics
             foreign key (review_rubric_id) references rubrics(id)"
    execute "alter table assignments
             add constraint fk_assignments_review_of_review_rubrics
             foreign key (review_of_review_rubric_id) references rubrics(id)"
    execute "alter table assignments
             add constraint fk_assignments_instructors
             foreign key (instructor_id) references users(id)"
  end

  def self.down
    drop_table :assignments
  end
end
