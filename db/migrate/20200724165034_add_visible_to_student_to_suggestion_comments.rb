class AddVisibleToStudentToSuggestionComments < ActiveRecord::Migration
  def change
    add_column :suggestion_comments, :visible_to_student, :boolean, :default => false
  end
end
