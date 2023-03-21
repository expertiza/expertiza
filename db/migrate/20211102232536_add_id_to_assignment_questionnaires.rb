class AddIdToAssignmentQuestionnaires < ActiveRecord::Migration[4.2]
  def change
    add_reference :assignment_questionnaires, :duty, index: true, foreign_key: true
  end
end
