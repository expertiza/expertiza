class CreateReviewMappings < ActiveRecord::Migration
  # This table should have essentially the same format as review_of_review_mappings
  def self.up
    create_table :review_mappings do |t|
      t.column :author_id, :integer # if an individual is being reviewed, this field is non-null, otherwise is null
      t.column :team_id, :integer   # if a team is being reviewed, this field is non-null, otherwise is null
      t.column :reviewer_id, :integer
      t.column :assignment_id, :integer  # assignment that is being reviewed
      t.column :review_num_for_author, :integer  # on author's review page, the review is listed as having this number
      t.column :review_num_for_reviewer, :integer  # on reviewer's review page, the review is listed as having this number
	# Understand that, in dynamically mapped reviews, reviewer A may review authors B and C, and may be the first
	# person to review both B and C.  So (s)he will be B's reviewer number 1 and C's reviewer number 1.  However, B
	# and C can't both be his review #1.
	# Ditto for team review, where teams get more reviews than each individual writes.
    end
    execute "alter table review_mappings 
          add constraint fk_review_mapping_assignments
          foreign key (assignment_id) references assignments(id)"
  end

  def self.down
    drop_table :review_mappings
  end
end
