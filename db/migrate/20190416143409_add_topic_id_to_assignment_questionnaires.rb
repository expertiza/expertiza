class AddTopicIdToAssignmentQuestionnaires < ActiveRecord::Migration[4.2]
  def change
    add_column :assignment_questionnaires, :topic_id, :integer
  end
end
