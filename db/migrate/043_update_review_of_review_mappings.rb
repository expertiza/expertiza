class UpdateReviewOfReviewMappings < ActiveRecord::Migration
  def self.up
    begin
<<<<<<< HEAD
    execute "ALTER TABLE `review_of_review_mappings` 
             DROP INDEX `fk_review_of_review_mapping_reviews`"
=======
<<<<<<< HEAD
<<<<<<< HEAD
    execute "ALTER TABLE `review_of_review_mappings` 
             DROP INDEX `fk_review_of_review_mapping_reviews`"
=======
    execute "ALTER TABLE `review_of_review_mappings` 
             DROP INDEX `fk_review_of_review_mapping_reviews`"
>>>>>>> c4cd6ee2acd0c2721114a9165e8bf6050a7dd1ee
=======
    execute "ALTER TABLE `review_of_review_mappings` 
             DROP INDEX `fk_review_of_review_mapping_reviews`"
>>>>>>> c4cd6ee2acd0c2721114a9165e8bf6050a7dd1ee
>>>>>>> 126e61ecf11c9abb3ccdba784bf9528251d30eb0
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
