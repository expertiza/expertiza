class ChangeCommentForReviewerInParticiantTableToText < ActiveRecord::Migration
  def self.up
  	change_column :participants, :comment_for_reviewer, :text, default: nil
  end

  def self.down
  	change_column :participants, :comment_for_reviewer, :string, default: ''
  end
end
