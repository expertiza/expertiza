class AddReviewerIdToReviewOfReviewMappings < ActiveRecord::Migration[4.2][4.2]
  def self.up
    begin
      add_column :review_of_review_mappings, :reviewer_id, :integer, :null => true
    rescue
    end

  end

  def self.down
  end
end
