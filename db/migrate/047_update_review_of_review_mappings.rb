class UpdateReviewOfReviewMappings < ActiveRecord::Migration
  def self.up
     # remove unnecessary columns from table 
     remove_column "review_of_review_mappings","assignment_id"
     remove_column "review_of_review_mappings","reviewer_id"
     
     execute "alter table `review_of_review_mappings` drop foreign key `fk_review_of_review_mapping_reviews`"
     execute "alter table `review_of_review_mappings` drop index `fk_review_of_review_mapping_reviews`"
     remove_column "review_of_review_mappings","review_id"
  end

  def self.down
  end
end
