class ChangeInstructorResponseScoreToFloat < ActiveRecord::Migration[5.1]
  def change
    change_column :instructor_response_scores, :score, :float
  end
end
