class StandardizeReviewOfReview < ActiveRecord::Migration
  def self.up
    remove_column :metareviews, :reviewed_at
    remove_column :metareviews, :review_num_for_author
    remove_column :metareviews, :review_num_for_reviewer
    add_column :metareviews, :additional_comment, :string, :null => true
    begin
    add_column :metareviews, :created_at, :datetime, :null => true
    add_column :metareviews, :updated_at, :datetime, :null => true
    rescue
    end
    
    execute "ALTER TABLE `metareviews`
             DROP FOREIGN KEY `fk_metareview_metareview_mappings`"
    execute "ALTER TABLE `metareviews`
             DROP INDEX `fk_metareview_metareview_mappings`"
             
    rename_column :metareviews, :metareview_mapping_id, :mapping_id
    
    execute "ALTER TABLE `metareviews`
             ADD CONSTRAINT `fk_metareview_metareview_mappings`
             FOREIGN KEY (mapping_id) references metareview_mappings(id)"
    
  end

  def self.down
  end
end
