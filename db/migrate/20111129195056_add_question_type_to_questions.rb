class AddQuestionTypeToQuestions < ActiveRecord::Migration
  def self.up
    add_column :questions, :question_type, :text
  end

  def self.down
    remove_column :questions, :question_type
  end
end
