class AddIdToAssignmentQuestionnaires < ActiveRecord::Migration
  def change
    add_reference :assignment_questionnaires, :duty, index: true, foreign_key: true
  end
end
