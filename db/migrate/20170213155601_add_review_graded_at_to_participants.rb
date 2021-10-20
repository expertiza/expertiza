class AddReviewGradedAtToParticipants < ActiveRecord::Migration
  def change
  	add_column :participants, :review_graded_at, :datetime
  end
end
