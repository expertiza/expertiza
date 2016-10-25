class UpdateReviewOfReviewMappings < ActiveRecord::Migration
  def self.up
    begin
    execute "ALTER TABLE `review_of_review_mappings` 
             DROP INDEX `fk_review_of_review_mapping_reviews`"
    rescue
    end
   
    begin
    execute "ALTER TABLE `review_of_review_mappings` 
             DROP FOREIGN KEY  `fk_review_of_review_mapping_reviews`"      
    rescue      
    end
    remove_column "review_of_review_mappings", "assignment_id"
    remove_column "review_of_review_mappings", "review_id"    
  end

  def self.down
  end
end
