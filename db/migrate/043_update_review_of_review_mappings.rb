class UpdateReviewOfReviewMappings < ActiveRecord::Migration
  def self.up
    begin
    execute "ALTER TABLE `metareview_mappings`
             DROP INDEX `fk_metareview_mapping_reviews`"
    rescue
    end
   
    begin
    execute "ALTER TABLE `metareview_mappings`
             DROP FOREIGN KEY  `fk_metareview_mapping_reviews`"
    rescue      
    end
    remove_column "metareview_mappings", "assignment_id"
    remove_column "metareview_mappings", "review_id"
  end

  def self.down
  end
end
