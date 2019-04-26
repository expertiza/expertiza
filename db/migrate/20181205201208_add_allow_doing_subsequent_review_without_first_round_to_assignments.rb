class AddAllowDoingSubsequentReviewWithoutFirstRoundToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :allow_selecting_additional_reviews_after_1st_round, :boolean
  end
end
