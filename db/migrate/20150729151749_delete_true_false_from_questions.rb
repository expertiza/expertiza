class DeleteTrueFalseFromQuestions < ActiveRecord::Migration[4.2]
  def change
    remove_column 'questions', 'true_false'
  end
end
