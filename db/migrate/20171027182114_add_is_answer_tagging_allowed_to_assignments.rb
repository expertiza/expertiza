class AddIsAnswerTaggingAllowedToAssignments < ActiveRecord::Migration[4.2]
  def change
    add_column :assignments, :is_answer_tagging_allowed, :boolean
  end
end
