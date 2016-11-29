class AddShowOtherReviewsToAssignments < ActiveRecord::Migration
  def self.up
    add_column :assignments, :show_other_reviews, :boolean, default: false
  end

  def self.down
    remove_column :assignments, :show_other_reviews
  end
end
