class AddIsAnswerTaggingAllowedToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :is_answer_tagging_allowed, :boolean, :default => false
  end
end
