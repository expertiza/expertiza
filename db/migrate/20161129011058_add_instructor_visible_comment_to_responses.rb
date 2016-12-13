class AddInstructorVisibleCommentToResponses < ActiveRecord::Migration
  def self.up
    add_column :responses, :instructor_visible_comment, :text
  end

  def self.down
    remove_column :responses, :instructor_visible_comment
  end
end
