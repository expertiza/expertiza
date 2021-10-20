class CreateReviewOfReviews < ActiveRecord::Migration
  # This table should have essentially the same format as (the table) reviews
  def self.up
    create_table :review_of_reviews do |t|
      t.column :reviewed_at, :datetime  # time that the review of review was saved
      t.column :review_of_review_mapping_id, :integer  # the entry in the review_of_review_mappings table that identifies reviewer and review
      t.column :review_num_for_author, :integer  # on reviewee's review page, the review is listed as having this number
      t.column :review_num_for_reviewer, :integer  # on reviewer's review page, the review is listed as having this number
	# Understand that, in dynamically mapped reviews, reviewer A may review reviewees B and C, and may be the first
	# entity to review both B and C.  So (s)he will be B's reviewer number 1 and C's reviewer number 1.  However, B
	# and C can't both be his review #1.
	# This logic caters for the situation where the entity doing the reivews of reviews is different than the entity
	# doing reviews (e.g., teams are doing the reviews (of other teams), whereas individuals are doing the reviews
	# of the reviews (that were done by teams)).
    end
    execute "alter table review_of_reviews 
             add constraint fk_review_of_review_review_of_review_mappings
             foreign key (review_of_review_mapping_id) references review_of_review_mappings(id)"
  end

  def self.down
    drop_table :review_of_reviews
  end
end
