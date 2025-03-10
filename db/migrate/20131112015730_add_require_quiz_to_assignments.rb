class AddRequireQuizToAssignments < ActiveRecord::Migration[4.2]
  def self.up
    add_column :assignments, :require_quiz, :boolean
  end

  def self.down
    remove_column :assignments, :require_quiz
  end
end
