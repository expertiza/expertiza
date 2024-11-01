class AddAllowDoingSubsequentReviewWithoutFirstRoundToAssignments < ActiveRecord::Migration[4.2]
  def change
    add_column :assignments, :allow_selecting_additional_reviews_after_1st_round, :boolean
  end
end
