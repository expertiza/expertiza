class AddQuizQuestionTypeQuizQuestionnaire < ActiveRecord::Migration
  def self.up
    add_column :questionnaires, :quiz_question_type, :text
  end

  def self.down
    delete_column :questionnaires, :quiz_question_type, :text
  end
end
