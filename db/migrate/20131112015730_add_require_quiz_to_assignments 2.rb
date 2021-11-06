class AddRequireQuizToAssignments < ActiveRecord::Migration
  def self.up
    add_column :assignments, :require_quiz, :boolean
  end

  def self.down
    remove_column :assignments, :require_quiz
  end
end
