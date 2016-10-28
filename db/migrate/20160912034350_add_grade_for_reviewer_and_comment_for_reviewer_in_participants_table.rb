class AddGradeForReviewerAndCommentForReviewerInParticipantsTable < ActiveRecord::Migration
  def self.up
  	# add_column :due_dates, :type, :string, null: :false, default: 'AssignmentDueDate'
  	add_column :participants, :grade_for_reviewer, :integer, default: nil
  	add_column :participants, :comment_for_reviewer, :string, default: ''
  end

  def self.down
  	remove_column :participants, :comment_for_reviewer
  	remove_column :participants, :grade_for_reviewer
  end
end
