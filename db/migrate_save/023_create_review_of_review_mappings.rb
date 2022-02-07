class CreateReviewOfReviewMappings < ActiveRecord::Migration
  # This table should have essentially the same format as review_mappings
  def self.up
    create_table :review_of_review_mappings do |t|
      t.column :review_mapping_id, :integer # the review that is being reviewed.  Note that the review_mapping_id allows us to retrieve reviews done by a particular reviewer of *all* versions of an author's submission.
      t.column :reviewer_id, :integer  # the id of the user reviewing this review.
      t.column :review_id, :integer  # review that is being reviewed
    end
    execute "alter table review_of_review_mappings
             add constraint fk_review_of_review_mapping_reviews
             foreign key (review_id) references reviews(id)"
    execute "alter table review_of_review_mappings
             add constraint fk_review_of_review_mapping_review_mappings
             foreign key (review_mapping_id) references review_mappings(id)"
  end

  def self.down
    drop_table :review_of_review_mappings
  end
end
