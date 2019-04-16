class AddTopicIdToAssignmentQuestionnaires < ActiveRecord::Migration
  def change
    add_column :assignment_questionnaires, :topic_id, :integer
  end
end
