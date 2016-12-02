class AddReviewLastGradedDateToParticipants < ActiveRecord::Migration
  def change
    add_column :participants, :review_last_graded_date, :datetime
  end
end
