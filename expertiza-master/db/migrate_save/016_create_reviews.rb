class CreateReviews < ActiveRecord::Migration
  # This table should have essentially the same format as review_of_reviews
  def self.up
    create_table :reviews do |t|
      t.column :reviewed_at, :datetime  # time that the review was saved
      t.column :review_mapping_id, :integer  # the entry in the review_mappings table identifies reviewer and reviewee
      t.column :review_num_for_author, :integer  # on author's review page, the review is listed as having this number
      t.column :review_num_for_reviewer, :integer  # on reviewer's review page, the review is listed as having this number
	# Understand that, in dynamically mapped reviews, reviewer A may review authors B and C, and may be the first
	# person to review both B and C.  So (s)he will be B's reviewer number 1 and C's reviewer number 1.  However, B
	# and C can't both be his review #1.
	# Ditto for team review, where teams get more reviews than each individual writes.
    end
    execute "alter table reviews
             add constraint fk_review_mappings
             foreign key (review_mapping_id) references review_mappings(id)"
  end

  def self.down
    drop_table :reviews
  end
end
