class RemoveQuestionTypesTable < ActiveRecord::Migration[4.2]
  def self.up
    drop_table :question_types
  end
end
