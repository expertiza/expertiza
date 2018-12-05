class AddAllowDoingSubsequentReviewWithoutFirstRoundToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :allow_doing_subsequent_review_without_first_round, :boolean
  end
end
