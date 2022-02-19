class ChangeCommentForReviewerInParticiantTableToText < ActiveRecord::Migration[4.2]
  def self.up
    change_column :participants, :comment_for_reviewer, :text, default: nil
  end

  def self.down
    change_column :participants, :comment_for_reviewer, :string, default: ''
  end
end
