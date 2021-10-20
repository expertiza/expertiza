class StandardizeReviewOfReview < ActiveRecord::Migration
  def self.up
    remove_column :review_of_reviews, :reviewed_at
    remove_column :review_of_reviews, :review_num_for_author
    remove_column :review_of_reviews, :review_num_for_reviewer
    add_column :review_of_reviews, :additional_comment, :string, :null => true
    begin
    add_column :review_of_reviews, :created_at, :datetime, :null => true
    add_column :review_of_reviews, :updated_at, :datetime, :null => true
    rescue
    end
    
    execute "ALTER TABLE `review_of_reviews` 
             DROP FOREIGN KEY `fk_review_of_review_review_of_review_mappings`"             
    execute "ALTER TABLE `review_of_reviews` 
             DROP INDEX `fk_review_of_review_review_of_review_mappings`"   
             
    rename_column :review_of_reviews, :review_of_review_mapping_id, :mapping_id             
    
    execute "ALTER TABLE `review_of_reviews` 
             ADD CONSTRAINT `fk_review_of_review_review_of_review_mappings`
             FOREIGN KEY (mapping_id) references review_of_review_mappings(id)"    
    
  end

  def self.down
  end
end
