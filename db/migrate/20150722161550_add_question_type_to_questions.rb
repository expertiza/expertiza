class AddQuestionTypeToQuestions < ActiveRecord::Migration[4.2]
  def self.up
    add_column 'questions', 'seq', :float, default: nil
    add_column 'questions', 'q_type', :string
    add_column 'questions', 'size', :string
    add_column 'questions', 'alternatives', :string
    add_column 'questions', 'break_before', :boolean, default: true
  end
end
