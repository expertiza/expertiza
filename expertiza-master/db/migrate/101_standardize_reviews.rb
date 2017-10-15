class StandardizeReviews < ActiveRecord::Migration
  def self.up
    remove_column :reviews, :review_num_for_author
    remove_column :reviews, :review_num_for_reviewer
    remove_column :reviews, :ignore
    
    execute "ALTER TABLE `reviews` 
             DROP FOREIGN KEY `fk_review_mappings`" 
    execute "ALTER TABLE `reviews` 
             DROP INDEX `fk_review_mappings`"  
             
    rename_column :reviews, :review_mapping_id, :mapping_id
        
  end

  def self.down
  end
end
