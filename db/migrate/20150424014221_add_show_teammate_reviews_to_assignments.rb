class AddShowTeammateReviewsToAssignments < ActiveRecord::Migration[4.2]
  def self.up
    add_column :assignments, :show_teammate_reviews, :boolean
  end

  def self.down
    remove_column :assignments, :show_teammate_reviews, :boolean
  end
end
