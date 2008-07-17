class UpdateReviewOfReviewMappings < ActiveRecord::Migration
  def self.up
    remove_column "review_of_review_mappings", :assignment_id, :reviewer_id, :review_id    
  end

  def self.down
  end
end
