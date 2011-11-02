class AddReviewerIdToReviewOfReviewMappings < ActiveRecord::Migration
  def self.up
    begin
      add_column :metareview_mappings, :reviewer_id, :integer, :null => true
    rescue
    end

  end

  def self.down
  end
end
