class AddReviewChoosingAlgorthmToAssignments < ActiveRecord::Migration[4.2]
  def self.up
    add_column :assignments, :bidding_for_reviews_enabled, :boolean, default: false
  end

  def self.down
    remove_column :assignments, :bidding_for_reviews_enabled
  end
end
