class AddReviewGradedAtToParticipants < ActiveRecord::Migration[4.2]
  def change
    add_column :participants, :review_graded_at, :datetime
  end
end
