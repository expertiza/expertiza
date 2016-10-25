class RemoveQuestionTypesTable < ActiveRecord::Migration
  def self.up
  	drop_table :question_types
  end
end
