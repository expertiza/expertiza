class AddIsSentToLlmForProcessingToAssignments < ActiveRecord::Migration[5.1]
  def change
    add_column :assignments,
               :is_sent_to_llm_for_processing,
               :boolean,
               default: false,
               null: false
  end
end
