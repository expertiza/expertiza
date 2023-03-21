class AddGradeForSubmissionAndCommentForSubmissionInTeamsTable < ActiveRecord::Migration[4.2]
  def self.up
    add_column :teams, :grade_for_submission, :integer, default: nil
    add_column :teams, :comment_for_submission, :text, default: nil
  end

  def self.down
    remove_column :teams, :comment_for_submission
    remove_column :teams, :grade_for_submission
  end
end
