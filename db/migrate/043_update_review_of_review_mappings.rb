class UpdateReviewOfReviewMappings < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE review_of_review_mappings 
             DROP FOREIGN KEY fk_review_of_review_mapping_reviews"
             
    remove_column "review_of_review_mappings", "assignment_id"
    remove_column "review_of_review_mappings", "reviewer_id"
    remove_column "review_of_review_mappings", "review_id"    
  end

  def self.down
  end
end
