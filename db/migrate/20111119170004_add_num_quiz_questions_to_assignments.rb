class AddNumQuizQuestionsToAssignments < ActiveRecord::Migration
  def self.up
    add_column :assignments, :num_quiz_questions, :integer, :default => 0, :null => false
  end

  def self.down
    remove_column :assignments, :num_quiz_questions
  end
end
