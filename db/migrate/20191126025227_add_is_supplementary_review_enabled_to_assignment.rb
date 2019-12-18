class AddIsSupplementaryReviewEnabledToAssignment < ActiveRecord::Migration
  def change
    add_column :assignments, :is_supplementary_review_enabled, :boolean
  end
end
