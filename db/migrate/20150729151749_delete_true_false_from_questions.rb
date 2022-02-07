class DeleteTrueFalseFromQuestions < ActiveRecord::Migration
  def change
    remove_column "questions","true_false"
  end
end
